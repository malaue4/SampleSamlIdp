# frozen_string_literal: true

require "test_helper"

module Saml
  module Metadata
    class EndpointTest < ActiveSupport::TestCase
      test "EndpointWithoutResponseLocation .parse from XML (SingleSignOnService)" do
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
        assert_not_respond_to endpoint, :response_location
      end

      test "EndpointWithResponseLocation .parse from XML (SingleLogoutService)" do
        xml = <<~XML
          <md:SingleLogoutService xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
            Location="https://idp.example.com/SAML2/SLO/Redirect"
            ResponseLocation="https://idp.example.com/SAML2/SLO/Response"/>
        XML
        node = Nokogiri::XML(xml).root
        endpoint = SingleLogoutService.parse(node)

        assert_instance_of SingleLogoutService, endpoint
        assert_equal "https://idp.example.com/SAML2/SLO/Response", endpoint.response_location
      end

      test "EndpointWithoutResponseLocation direct construction and to_xml" do
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
        assert_no_match /ResponseLocation/, xml
      end

      test "IndexedEndpointWithoutResponseLocation (ArtifactResolutionService)" do
        xml = <<~XML
          <md:ArtifactResolutionService xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"
            Location="https://idp.example.com/SAML2/Artifact"
            index="1"
            isDefault="true"
            ResponseLocation="https://idp.example.com/SAML2/ArtifactResponse"/>
        XML
        node = Nokogiri::XML(xml).root
        endpoint = ArtifactResolutionService.parse(node)

        assert_instance_of ArtifactResolutionService, endpoint
        assert_equal 1, endpoint.index
        assert_not_respond_to endpoint, :response_location

        xml = endpoint.to_xml
        assert_no_match /ResponseLocation/, xml
      end

      test "IndexedEndpointWithResponseLocation (AssertionConsumerService)" do
        xml = <<~XML
          <md:AssertionConsumerService xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
            Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
            Location="https://sp.example.com/SAML2/ACS/POST"
            ResponseLocation="https://sp.example.com/SAML2/ACS/Response"
            index="1"
            isDefault="true"/>
        XML
        node = Nokogiri::XML(xml).root
        endpoint = AssertionConsumerService.parse(node)

        assert_instance_of AssertionConsumerService, endpoint
        assert_equal "https://sp.example.com/SAML2/ACS/Response", endpoint.response_location
        assert_equal 1, endpoint.index
        assert_equal true, endpoint.default

        xml = endpoint.to_xml
        assert_match /ResponseLocation="https:\/\/sp.example.com\/SAML2\/ACS\/Response"/, xml
      end
    end
  end
end
