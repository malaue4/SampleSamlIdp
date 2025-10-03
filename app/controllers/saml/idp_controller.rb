# frozen_string_literal: true

module Saml
  class IdpController < ApplicationController
    include SamlIdp::Controller

    protect_from_forgery

    attr_reader :saml_request

    before_action :require_saml_request, only: [ :new, :create, :logout ]
    skip_before_action :authenticate_user!

    def new
      @metadata = SamlMetadatum.find_by entity_id: saml_request&.issuer_entity_id

      return unless @metadata
      saml_request.metadata = @metadata
      saml_request.validate!
    end

    def show
      render xml: SamlIdp.metadata.signed
    end

    def create
      if params[:commit] == "Cancel"
        @saml_response = idp_make_saml_failure_response error: "Request cancelled by user"
        render template: "saml/idp/saml_post", layout: false
        return
      end
      unless user_params[:username].blank? && user_params[:password].blank?
        person = idp_authenticate(user_params[:username], user_params[:password])
        if person.nil?
          @saml_idp_fail_msg = "Incorrect username or password."
        else
          user_session = person.user_sessions.create!
          session[:session_id] = user_session.id
          @saml_response = idp_make_saml_response(person)
          render template: "saml/idp/saml_post", layout: false
          return
        end
      end
      render template: "saml/idp/new"
    end

    def logout
      idp_logout
      @saml_response = idp_make_saml_response(nil)
      render template: "saml/idp/saml_post", layout: false, locals: { saml_acs_url: saml_request.logout_url || "http://localhost:5000/saml/sp/logins/slo" }
    end

    def attributes
      @saml_request = decode_request params[:SAMLRequest]
      @saml_request.valid?
      # TODO: Implement AttributeAuthorityService
    end

    def idp_logout
      user = User.find_by(name_id: saml_request.name_id)
      # user.logout
    end
    private :idp_logout

    def idp_authenticate(username, password)
      user = User.find_by(username: username)
      user && user.authenticate(password) ? user : nil
    end
    protected :idp_authenticate

    def idp_make_saml_response(person)
      # NOTE encryption is optional
      encode_response person, encryption: {
        cert: saml_request.service_provider.cert,
        block_encryption: "aes256-cbc",
        key_transport: "rsa-oaep-mgf1p"
      }
    end
    protected :idp_make_saml_response

    def idp_make_saml_failure_response(error: "Something went wrong")
      # NOTE encryption is optional
      encode_failure_response idp_entity_id: SamlIdp.config.entity_id, error:, saml_request_id: saml_request&.request_id
    end
    protected :idp_make_saml_response

    private

      def user_params
        params.fetch(:user, {}).permit(:username, :password)
      end

      def user_session
        @user_session ||= UserSession.find_by(id: session[:session_id])
      end

      def current_user
        @current_user ||= user_session&.user
      end

      protected def validate_saml_request(raw_saml_request = params[:SAMLRequest])
        decode_request(raw_saml_request)
        return true if valid_saml_request?

        false
      end

      def encode_failure_response(idp_entity_id:, error:, saml_request_id: nil, destination: saml_acs_url)
        response_attributes = {}
        response_attributes[:ID] = "_#{SecureRandom.uuid}"
        response_attributes[:Version] = "2.0"
        response_attributes[:IssueInstant] = Time.current.utc.iso8601
        response_attributes[:Destination] = destination
        response_attributes[:Consent] = Saml::XML::Namespaces::Consents::UNSPECIFIED
        response_attributes[:InResponseTo] = saml_request_id unless saml_request_id.nil?
        response_attributes["xmlns:samlp"] = Saml::XML::Namespaces::PROTOCOL

        xml = Builder::XmlMarkup.new
        xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
        xml.tag! :samlp, :Response, response_attributes do |res|
          res.Issuer idp_entity_id, xmlns: "urn:oasis:names:tc:SAML:2.0:assertion"
          build_signature_markup xml, response_attributes[:ID] if true # should sign response?
          res.tag! :samlp, :Status do |status|
            status.tag! :samlp, :StatusCode, Value: "urn:oasis:names:tc:SAML:2.0:status:Responder" do |code|
              code.tag! :samlp, :StatusCode, Value: "urn:oasis:names:tc:SAML:2.0:status:AuthnFailed"
            end
            status.tag! :samlp, :StatusMessage, error
          end
        end

        unsigned_xml = xml.target!

        signed_xml = if true # sign_response?
          Xmldsig::SignedDocument.new(unsigned_xml).sign(SamlIdp.config.secret_key)
        else
          unsigned_xml
        end

        Base64.strict_encode64(signed_xml)
      end

    SIGNATURE_ALGORITHMS = {
      rsa_sha1: "http://www.w3.org/2000/09/xmldsig#rsa-sha1",
      rsa_sha256: "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256",
      rsa_sha384: "http://www.w3.org/2001/04/xmldsig-more#rsa-sha384",
      rsa_sha512: "http://www.w3.org/2001/04/xmldsig-more#rsa-sha512",
      dsa_sha1: "http://www.w3.org/2000/09/xmldsig#dsa-sha1",
      dsa_sha256: "http://www.w3.org/2009/xmldsig11#dsa-sha256"
    }.freeze

    # Builds an XML markup for a digital signature according to the XML DSig specification.
    #
    # This method constructs the XML structure required for signing data using
    # a digital signature algorithm. It creates a "Signature" element containing
    # "SignedInfo", "CanonicalizationMethod", "SignatureMethod", and "Reference" elements.
    # The algorithm used for signing can be specified by the `signature_algorithm` parameter.
    #
    # Parameters:
    # - xml: The Builder::XmlMarkup object used to generate XML.
    # - reference_id: A unique identifier for the signature, inserted as the "Id" attribute of the "Signature" element.
    # - signature_algorithm: A symbol representing the digital signature algorithm to use. Defaults to `:rsa_sha1`.
    #
    # Returns:
    # - nil: XML markup is appended to the provided xml object, and no explicit value is returned.
    def build_signature_markup(xml, reference_id, signature_algorithm: :rsa_sha1)
      xml.dsig :Signature, Id: reference_id, xmlns: "http://www.w3.org/2000/09/xmldsig#" do |sig|
        sig.dsig :SignedInfo, xmlns: "http://www.w3.org/2000/09/xmldsig#" do |signed_info|
          signed_info.dsig :CanonicalizationMethod, Algorithm: "http://www.w3.org/TR/2001/REC-xml-c14n-20010315"
          signed_info.dsig :SignatureMethod, Algorithm: SIGNATURE_ALGORITHMS.fetch(signature_algorithm)
          signed_info.dsig :Reference, URI: "##{reference_id}" do |reference|
            reference.dsig :Transforms, xmlns: "http://www.w3.org/2000/09/xmldsig#" do |transforms|
              transforms.dsig :Transform, Algorithm: "http://www.w3.org/2000/09/xmldsig#enveloped-signature"
            end
          end
        end
        sig.dsig :SignatureValue
      end
    end

      def require_saml_request
        @saml_request = Request.parse(params.require(:SAMLRequest))
      end
  end
end
