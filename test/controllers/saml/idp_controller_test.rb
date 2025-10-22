require "test_helper"

module Saml
  class IdpControllerTest < ActionDispatch::IntegrationTest

    describe "#create" do
      test "cancel_create_action" do
        auth_request = Saml::Request::Encoding.encode Saml::Request::Compression.deflate <<~XML
          <AuthnRequest xmlns="#{Saml::Namespaces::SAMLP}" ID="lol" Version="2.0" IssueInstant="2013-03-18T03:24:19Z">
          </AuthnRequest>
        XML
        post "/saml/auth", params: { SAMLRequest: auth_request, submit: "Cancel" }




        assert_match(/Status: urn:oasis:names:tc:SAML:2.0:status:Responder/, response.body)
        assert_response :success
      end
    end
  end
end
