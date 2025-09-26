require "test_helper"

describe Saml::IdpController do
  describe "#create" do
    test "cancel_create_action" do
      post "/saml/auth", params: { submit: "Cancel" }
      assert_match(/Status: urn:oasis:names:tc:SAML:2.0:status:Responder/, response.body)
      assert_response :success
    end
  end
end
