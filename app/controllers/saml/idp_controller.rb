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
      render template: "saml/idp/saml_post", layout: false
    end

    def attributes
      @saml_request = decode_request params[:SAMLRequest]
      @saml_request.valid?
      # TODO: Implement AttributeAuthorityService
    end

    def idp_logout
      user = User.find_by(name_id: saml_request.name_id)
      user.logout
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
  end
end
