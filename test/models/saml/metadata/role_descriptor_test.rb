# frozen_string_literal: true

require "test_helper"

module Saml
  module Metadata
    class RoleDescriptorTest < ActiveSupport::TestCase
      test "parse RoleDescriptor" do
        xml = <<~XML
          <md:RoleDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
            protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol"
            errorURL="http://example.com/error" />
        XML
        node = Nokogiri::XML(xml).at_xpath("//md:RoleDescriptor", "md" => Namespaces::MD)
        rd = RoleDescriptor.parse(node)

        assert_instance_of RoleDescriptor, rd
        assert_equal "urn:oasis:names:tc:SAML:2.0:protocol", rd.protocol_support_enumeration
        assert_equal "http://example.com/error", rd.error_url
      end

      test "parse IDPSSODescriptor" do
        xml = <<~XML
          <md:IDPSSODescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
            protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol"
            WantAuthnRequestsSigned="true">
            <md:NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient</md:NameIDFormat>
            <md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="http://idp.example.com/sso" />
          </md:IDPSSODescriptor>
        XML
        node = Nokogiri::XML(xml).at_xpath("//md:IDPSSODescriptor", "md" => Namespaces::MD)
        idp = RoleDescriptor.parse(node)

        assert_instance_of IdentityProviderSingleSignOnDescriptor, idp
        assert_equal "urn:oasis:names:tc:SAML:2.0:protocol", idp.protocol_support_enumeration
        assert_equal true, idp.want_authn_requests_signed
        assert_equal [ "urn:oasis:names:tc:SAML:2.0:nameid-format:transient" ], idp.name_id_formats
        assert_equal 1, idp.single_sign_on_services.size
        assert_equal "http://idp.example.com/sso", idp.single_sign_on_services.first.location
      end

      test "parse SPSSODescriptor" do
        xml = <<~XML
          <md:SPSSODescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
            protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol"
            AuthnRequestsSigned="true"
            WantAssertionsSigned="false">
            <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="http://sp.example.com/acs" index="0" />
          </md:SPSSODescriptor>
        XML
        node = Nokogiri::XML(xml).at_xpath("//md:SPSSODescriptor", "md" => Namespaces::MD)
        sp = RoleDescriptor.parse(node)

        assert_instance_of ServiceProviderSingleSignOnDescriptor, sp
        assert_equal "urn:oasis:names:tc:SAML:2.0:protocol", sp.protocol_support_enumeration
        assert_equal true, sp.authn_requests_signed
        assert_equal false, sp.want_assertions_signed
        assert_equal 1, sp.assertion_consumer_services.size
        assert_equal "http://sp.example.com/acs", sp.assertion_consumer_services.first.location
      end

      test "direct construction and to_xml for IDPSSODescriptor" do
        sso_service = SingleSignOnService.new(binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect", location: "http://idp.example.com/sso")
        idp = IdentityProviderSingleSignOnDescriptor.new(
          protocol_support_enumeration: "urn:oasis:names:tc:SAML:2.0:protocol",
          want_authn_requests_signed: true,
          name_id_formats: [ "urn:oasis:names:tc:SAML:2.0:nameid-format:transient" ],
          single_sign_on_services: [ sso_service ]
        )

        xml = idp.to_xml
        assert_match /<md:IDPSSODescriptor/, xml
        assert_match /protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol"/, xml
        assert_match /WantAuthnRequestsSigned="true"/, xml
        assert_match /<md:NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient<\/md:NameIDFormat>/, xml
        assert_match /<md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="http:\/\/idp.example.com\/sso"\/>/, xml
      end

      test "direct construction and to_xml for SPSSODescriptor" do
        acs = AssertionConsumerService.new(binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST", location: "http://sp.example.com/acs", index: 0)
        sp = ServiceProviderSingleSignOnDescriptor.new(
          protocol_support_enumeration: "urn:oasis:names:tc:SAML:2.0:protocol",
          authn_requests_signed: true,
          want_assertions_signed: true,
          assertion_consumer_services: [ acs ]
        )

        xml = sp.to_xml
        assert_match /<md:SPSSODescriptor/, xml
        assert_match /AuthnRequestsSigned="true"/, xml
        assert_match /WantAssertionsSigned="true"/, xml
        assert_match /<md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="http:\/\/sp.example.com\/acs" index="0" isDefault="false"\/>/, xml
      end
    end
  end
end
