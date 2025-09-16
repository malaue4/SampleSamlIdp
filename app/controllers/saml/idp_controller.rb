# frozen_string_literal: true

module Saml
  class IdpController < ApplicationController
    include SamlIdp::Controller

    protect_from_forgery

    before_action :validate_saml_request, only: [ :new, :create, :logout ]

    def new
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
          # Maybe this should be signed, but I'll be damned if I can unravel saml_idp gem enough to figure out how it does
          # the signatures
          res.tag! :samlp, :Status do |status|
            status.tag! :samlp, :StatusCode, Value: "urn:oasis:names:tc:SAML:2.0:status:Responder" do |code|
              code.tag! :samlp, :StatusCode, Value: "urn:oasis:names:tc:SAML:2.0:status:AuthnFailed"
            end
            status.tag! :samlp, :StatusMessage, error
          end
        end

        Base64.strict_encode64(xml.target!)
      end
      # rubocop:enable Metrics/AbcSize
  end
end
