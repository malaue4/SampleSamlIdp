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
      unless user_params[:email].blank? && user_params[:password].blank?
        person = idp_authenticate(user_params[:email], user_params[:password])
        if person.nil?
          @saml_idp_fail_msg = "Incorrect email or password."
        else
          person.user_sessions.create!
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
      render template: "saml/idp/saml_post", layout: false
    end

    def attributes
      @saml_request = decode_request params[:SAMLRequest]
      @saml_request.valid?
    end

    def idp_logout
      user = User.find_by_email(saml_request.name_id)
      user.logout
    end
    private :idp_logout

    def idp_authenticate(email, password)
      user = User.find_by_email(email)
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

    private

      def user_params
        params.fetch(:user, {}).permit(:email, :password)
      end
  end
end
