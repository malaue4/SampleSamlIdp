# frozen_string_literal: true

require "test_helper"

module Saml
  module Dsig
    class SignatureTest < ActiveSupport::TestCase
      SAMPLE_XML = <<~XML
        <ds:Signature Id="sig1" xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
          <ds:SignedInfo Id="info1">
            <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
            <ds:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/>
            <ds:Reference URI="#_123">
              <ds:Transforms>
                <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
                <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
              </ds:Transforms>
              <ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
              <ds:DigestValue>dGhpcyBpcyBhIGRpZ2VzdA==</ds:DigestValue>
            </ds:Reference>
          </ds:SignedInfo>
          <ds:SignatureValue>c2lnbmF0dXJlIHZhbHVl</ds:SignatureValue>
          <ds:KeyInfo>
            <ds:KeyName>Test Key</ds:KeyName>
          </ds:KeyInfo>
        </ds:Signature>
      XML

      test "parse signature" do
        element = Nokogiri::XML(SAMPLE_XML).root
        signature = Signature.parse(element)

        assert_equal "sig1", signature.id
        assert_equal "c2lnbmF0dXJlIHZhbHVl", signature.signature_value
        assert_not_nil signature.signed_info
        assert_equal "info1", signature.signed_info.id
        assert_equal "http://www.w3.org/2001/10/xml-exc-c14n#", signature.signed_info.canonicalization_method
        assert_equal "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256", signature.signed_info.signature_method

        assert_equal 1, signature.signed_info.references.size
        ref = signature.signed_info.references.first
        assert_equal "#_123", ref.uri
        assert_equal "http://www.w3.org/2001/04/xmlenc#sha256", ref.digest_method
        assert_equal "dGhpcyBpcyBhIGRpZ2VzdA==", ref.digest_value

        assert_equal 2, ref.transforms.size
        assert_equal "http://www.w3.org/2000/09/xmldsig#enveloped-signature", ref.transforms.first.algorithm

        assert_not_nil signature.key_info
        assert_equal [ "Test Key" ], signature.key_info.key_names
      end

      test "build_xml round-trip" do
        element = Nokogiri::XML(SAMPLE_XML).root
        signature = Signature.parse(element)

        xml = signature.to_xml
        doc = Nokogiri::XML(xml)

        assert_equal "sig1", doc.root["Id"]
        assert_equal "c2lnbmF0dXJlIHZhbHVl", doc.at_xpath("//ds:SignatureValue", ds: Namespaces::DS).text
        assert_equal "http://www.w3.org/2001/10/xml-exc-c14n#", doc.at_xpath("//ds:CanonicalizationMethod", ds: Namespaces::DS)["Algorithm"]
        assert_equal "#_123", doc.at_xpath("//ds:Reference", ds: Namespaces::DS)["URI"]
        assert_equal 2, doc.xpath("//ds:Transform", ds: Namespaces::DS).size
        assert_equal "Test Key", doc.at_xpath("//ds:KeyName", ds: Namespaces::DS).text
      end

      test "build_xml from scratch" do
        transform = Transform.new(algorithm: "http://www.w3.org/2001/10/xml-exc-c14n#")
        reference = Reference.new(
          uri: "#_456",
          transforms: [ transform ],
          digest_method: "http://www.w3.org/2001/04/xmlenc#sha256",
          digest_value: "YWJj"
        )
        signed_info = SignedInfo.new(
          canonicalization_method: "http://www.w3.org/2001/10/xml-exc-c14n#",
          signature_method: "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256",
          references: [ reference ]
        )
        signature = Signature.new(
          id: "sig2",
          signed_info: signed_info,
          signature_value: "eHl6"
        )

        xml = signature.to_xml
        doc = Nokogiri::XML(xml)

        assert_equal "Signature", doc.root.name
        assert_equal "sig2", doc.root["Id"]
        assert_equal "eHl6", doc.at_xpath("//ds:SignatureValue", ds: Namespaces::DS).text
        assert_equal "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256", doc.at_xpath("//ds:SignatureMethod", ds: Namespaces::DS)["Algorithm"]
        assert_equal "#_456", doc.at_xpath("//ds:Reference", ds: Namespaces::DS)["URI"]
        assert_equal "YWJj", doc.at_xpath("//ds:DigestValue", ds: Namespaces::DS).text
      end
    end
  end
end
