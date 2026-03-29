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
        auth_request = Saml::Encoding.encode Saml::Compression.deflate <<~XML
          <AuthnRequest xmlns="#{Saml::Namespaces::SAMLP}" xmlns:saml="#{Namespaces::SAML}" ID="lol" Version="2.0" IssueInstant="2013-03-18T03:24:19Z">
            <saml:Issuer>https://sp.example.com/sp/shibboleth</Issuer>
          </AuthnRequest>
        XML
        post "/saml/auth", params: { SAMLRequest: auth_request, commit: "Cancel" }

        saml_response = Capybara.string(response.body).find("#SAMLResponse", visible: false)["value"]
        saml_response = StatusResponse.parse(saml_response)

        jolly = {
          code: saml_response.status.status_code.value,
          message: saml_response.status.status_message,
          sub_code: saml_response.status.status_code.status_code.value,
        }

        assert_response :success
        assert_equal(
          {
            code: "urn:oasis:names:tc:SAML:2.0:status:Responder",
            message: "Request cancelled by user",
            sub_code: "urn:oasis:names:tc:SAML:2.0:status:AuthnFailed",
          },
          jolly,
          "Expected a AuthnFailed sub status code",
        )
      end
    end
  end
end
