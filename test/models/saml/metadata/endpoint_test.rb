# frozen_string_literal: true

require "test_helper"

module Saml
  module Metadata
    class EndpointTest < ActiveSupport::TestCase
      test "Endpoint .parse from XML" do
        xml = <<~XML
          <md:SingleSignOnService xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
            Location="https://idp.example.com/SAML2/SSO/Redirect"
            ResponseLocation="https://idp.example.com/SAML2/SSO/Response"/>
        XML
        node = Nokogiri::XML(xml).root
        endpoint = SingleSignOnService.parse(node)

        assert_instance_of SingleSignOnService, endpoint
        assert_equal "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect", endpoint.binding
        assert_equal "https://idp.example.com/SAML2/SSO/Redirect", endpoint.location
        assert_equal "https://idp.example.com/SAML2/SSO/Response", endpoint.response_location
      end

      test "Endpoint direct construction and to_xml" do
        endpoint = SingleSignOnService.new(
          binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
          location: "https://idp.example.com/SAML2/SSO/POST"
        )

        assert_equal "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST", endpoint.binding
        assert_equal "https://idp.example.com/SAML2/SSO/POST", endpoint.location

        xml = endpoint.to_xml
        assert_match /md:SingleSignOnService/, xml
        assert_match /Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"/, xml
        assert_match /Location="https:\/\/idp.example.com\/SAML2\/SSO\/POST"/, xml
      end

      test "IndexedEndpoint .parse from XML" do
        xml = <<~XML
          <md:AssertionConsumerService xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
            Location="https://sp.example.com/SAML2/ACS/POST"
            index="1"
            isDefault="true"/>
        XML
        node = Nokogiri::XML(xml).root
        endpoint = AssertionConsumerService.parse(node)

        assert_instance_of AssertionConsumerService, endpoint
        assert_equal "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST", endpoint.binding
        assert_equal "https://sp.example.com/SAML2/ACS/POST", endpoint.location
        assert_equal 1, endpoint.index
        assert_equal true, endpoint.default
      end

      test "IndexedEndpoint direct construction and to_xml" do
        endpoint = AssertionConsumerService.new(
          binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact",
          location: "https://sp.example.com/SAML2/ACS/Artifact",
          index: 2,
          default: false
        )

        assert_equal "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact", endpoint.binding
        assert_equal 2, endpoint.index
        assert_equal false, endpoint.default

        xml = endpoint.to_xml
        assert_match /md:AssertionConsumerService/, xml
        assert_match /index="2"/, xml
        assert_match /isDefault="false"/, xml
      end
    end
  end
end
