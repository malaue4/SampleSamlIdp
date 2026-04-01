# frozen_string_literal: true

require "test_helper"

module Saml
  module Metadata
    class SingleSignOnServiceTest < ActiveSupport::TestCase
      def test_parse_from_xml
        xml = <<~XML
          <md:SingleSignOnService xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
            Location="https://idp.example.com/SAML2/SSO/Redirect" />
        XML
        node = Nokogiri::XML(xml).at_xpath("//md:SingleSignOnService", "md" => Namespaces::MD)
        sso_service = SingleSignOnService.parse(node)

        assert_equal "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect", sso_service.binding
        assert_equal "https://idp.example.com/SAML2/SSO/Redirect", sso_service.location
        assert_nil sso_service.response_location
      end

      def test_direct_construction
        sso_service = SingleSignOnService.new(
          binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
          location: "https://idp.example.com/SAML2/SSO/POST"
        )

        assert_equal "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST", sso_service.binding
        assert_equal "https://idp.example.com/SAML2/SSO/POST", sso_service.location
        assert sso_service.valid?
      end

      def test_to_xml_omits_response_location
        # Even if someone tries to set it, it should be omitted in XML as per specification
        sso_service = SingleSignOnService.new(
          binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect",
          location: "https://idp.example.com/SAML2/SSO/Redirect",
          response_location: "https://idp.example.com/SAML2/SSO/Response"
        )

        xml = sso_service.to_xml
        assert_match /Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"/, xml
        assert_match /Location="https:\/\/idp.example.com\/SAML2\/SSO\/Redirect"/, xml
        refute_match /ResponseLocation/, xml
      end

      def test_validation_rejects_response_location
        sso_service = SingleSignOnService.new(
          binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect",
          location: "https://idp.example.com/SAML2/SSO/Redirect",
          response_location: "https://idp.example.com/SAML2/SSO/Response"
        )

        refute sso_service.valid?
        assert_includes sso_service.errors[:response_location], "must be blank"
      end
    end
  end
end
