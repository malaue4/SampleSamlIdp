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
    end
  end
end
