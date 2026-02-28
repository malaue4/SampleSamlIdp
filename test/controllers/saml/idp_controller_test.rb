require "test_helper"

module Saml
  class IdpControllerTest < ActionDispatch::IntegrationTest

    describe "#create" do
      before do
        SamlMetadatum.create!(
          entity_id: "https://sp.example.com/sp/shibboleth",
          metadata_url: "",
          config: {},
          assertion_consumer_service_url: "https://sp.example.com/sp/profile/SAML2/Redirect/SSO",
        )
      end

      test "cancel_create_action" do
        auth_request = Saml::Request::Encoding.encode Saml::Request::Compression.deflate <<~XML
          <AuthnRequest xmlns="#{Saml::Namespaces::SAMLP}" xmlns:saml="#{Namespaces::SAML}" ID="lol" Version="2.0" IssueInstant="2013-03-18T03:24:19Z">
            <saml:Issuer>https://sp.example.com/sp/shibboleth</Issuer>
          </AuthnRequest>
        XML
        post "/saml/auth", params: { SAMLRequest: auth_request, commit: "Cancel" }

        saml_response = Capybara.string(response.body).find("#SAMLResponse", visible: false)["value"]
        saml_response = StatusResponse.parse(saml_response)

        assert_match(/Status: urn:oasis:names:tc:SAML:2.0:status:Responder/, saml_response.status)
        assert_response :success
      end
    end
  end
end
