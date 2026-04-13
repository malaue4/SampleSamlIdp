# frozen_string_literal: true

require "test_helper"

module Saml
  class StatusResponseTest < ActiveSupport::TestCase
    SUCCESS_RESPONSE_XML = <<~XML
      <samlp:Response xmlns:samlp="#{Namespaces::SAMLP}" xmlns:saml="#{Namespaces::SAML}" ID="_123" InResponseTo="_abc" Version="2.0" IssueInstant="2024-07-01T12:00:00Z" Destination="http://sp.example.com/saml/consume">
        <saml:Issuer>http://idp.example.com</saml:Issuer>
        <samlp:Status>
          <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>
        </samlp:Status>
      </samlp:Response>
XML

    RESPONSE_WITH_EXTENSIONS_AND_SIG_XML = <<~XML
      <samlp:Response xmlns:samlp="#{Namespaces::SAMLP}" xmlns:saml="#{Namespaces::SAML}" xmlns:ds="#{Namespaces::DS}" ID="_456" Version="2.0" IssueInstant="2024-07-01T12:00:00Z">
        <saml:Issuer>http://idp.example.com</saml:Issuer>
        <ds:Signature Id="sig1">
          <ds:SignedInfo>
            <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
            <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
            <ds:Reference URI="#_456">
              <ds:Transforms>
                <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
              </ds:Transforms>
              <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
              <ds:DigestValue>YWJj</ds:DigestValue>
            </ds:Reference>
          </ds:SignedInfo>
          <ds:SignatureValue>eHl6</ds:SignatureValue>
        </ds:Signature>
        <samlp:Extensions>
          <foo:bar xmlns:foo="http://example.com/foo">baz</foo:bar>
        </samlp:Extensions>
        <samlp:Status>
          <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>
        </samlp:Status>
      </samlp:Response>
XML

    test "parse success response" do
      response = StatusResponse.parse(SUCCESS_RESPONSE_XML)
      assert_instance_of Response, response
      assert_equal "_123", response.id
      assert_equal "_abc", response.in_response_to
      assert_equal "http://idp.example.com", response.issuer.value
      assert_equal "urn:oasis:names:tc:SAML:2.0:status:Success", response.status.status_code.value
    end

    test "parse response with extensions and signature" do
      response = StatusResponse.parse(RESPONSE_WITH_EXTENSIONS_AND_SIG_XML)
      assert_not_nil response.signature
      assert_equal "sig1", response.signature.id
      assert_equal "eHl6", response.signature.signature_value
      
      assert_not_nil response.extensions
      assert_match /foo:bar/, response.extensions.content
      assert_match /baz/, response.extensions.content
    end

    test "build_xml" do
      issuer = NameId.new(value: "http://idp.example.com")
      status = Status.new(status_code: StatusCode.new(value: "urn:oasis:names:tc:SAML:2.0:status:Success"))
      response = Response.new(
        id: "_789",
        issue_instant: Time.parse("2024-07-01T12:00:00Z"),
        issuer: issuer,
        status: status
      )

      xml = response.to_xml
      document = Nokogiri::XML(xml)
      
      assert_equal "Response", document.root.name
      assert_equal "_789", document.root["ID"]
      assert_equal "http://idp.example.com", document.at_xpath("//saml:Issuer", saml: Namespaces::SAML).text
      assert_equal "urn:oasis:names:tc:SAML:2.0:status:Success", document.at_xpath("//samlp:StatusCode", samlp: Namespaces::SAMLP)["Value"]
    end
    
    test "build_xml with signature and extensions" do
      issuer = NameId.new(value: "http://idp.example.com")
      status = Status.new(status_code: StatusCode.new(value: "urn:oasis:names:tc:SAML:2.0:status:Success"))
      
      # Mocking signature and extensions for build_xml test
      sig_node = Nokogiri::XML("<ds:Signature xmlns:ds='#{Namespaces::DS}' Id='sig2'><ds:SignatureValue>sigval</ds:SignatureValue></ds:Signature>").root
      signature = Dsig::Signature.parse(sig_node)
      
      ext_node = Nokogiri::XML("<samlp:Extensions xmlns:samlp='#{Namespaces::SAMLP}'><my:Ext xmlns:my='urn:my'>val</my:Ext></samlp:Extensions>").root
      extensions = Extensions.parse(ext_node)
      
      response = Response.new(
        id: "_101",
        issue_instant: Time.parse("2024-07-01T12:00:00Z"),
        issuer: issuer,
        status: status,
        signature: signature,
        extensions: extensions
      )

      xml = response.to_xml
      document = Nokogiri::XML(xml)
      
      assert_equal "sig2", document.at_xpath("//ds:Signature", ds: Namespaces::DS)["Id"]
      assert_equal "sigval", document.at_xpath("//ds:SignatureValue", ds: Namespaces::DS).text
      assert_not_nil document.at_xpath("//samlp:Extensions", samlp: Namespaces::SAMLP)
      assert_equal "val", document.at_xpath("//my:Ext", my: "urn:my").text
    end
  end
end
