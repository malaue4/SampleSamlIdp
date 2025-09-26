# frozen_string_literal: true

require "test_helper"

module Saml
  class RequestTest < Minitest::Test

    AUTHN_REQUEST_XML = <<-XML
      <samlp:AuthnRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="id-1234567890" Version="2.0" IssueInstant="2013-03-18T03:24:19Z" Destination="https://idp.example.com/idp/profile/SAML2/Redirect/SSO" ProtocolBinding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect">
        <saml:Issuer>https://idp.example.com/idp/shibboleth</saml:Issuer>
        <samlp:NameIDPolicy Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified" AllowCreate="true"/>
      </samlp:AuthnRequest>
    XML
    DEFLATED_AUTHN_REQUEST_XML = Request::Encoding.encode(Request::Compression.deflate(AUTHN_REQUEST_XML))
    UNDEFLATED_AUTHN_REQUEST_XML = Request::Encoding.encode(AUTHN_REQUEST_XML)

    UNSIGNED_XML_REQUEST_XML = <<~XML
      <samlp:AuthnRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="pfx41d8ef22-e612-8c50-9960-1b16f15741b3" Version="2.0" ProviderName="SP test" IssueInstant="2014-07-16T23:52:45Z" Destination="http://idp.example.com/SSOService.php" ProtocolBinding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" AssertionConsumerServiceURL="http://sp.example.com/demo1/index.php?acs">
        <saml:Issuer>http://sp.example.com/demo1/metadata.php</saml:Issuer>
        <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
          <ds:SignedInfo>
            <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
            <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
            <ds:Reference URI="#pfx41d8ef22-e612-8c50-9960-1b16f15741b3">
              <ds:Transforms>
                <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
                <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
              </ds:Transforms>
              <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
              <ds:DigestValue></ds:DigestValue>
            </ds:Reference>
          </ds:SignedInfo>
          <ds:SignatureValue></ds:SignatureValue>
          <ds:KeyInfo>
            <ds:X509Data>
              <ds:X509Certificate></ds:X509Certificate>
            </ds:X509Data>
          </ds:KeyInfo>
        </ds:Signature>
        <samlp:NameIDPolicy Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress" AllowCreate="true"/>
        <samlp:RequestedAuthnContext Comparison="exact">
          <saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</saml:AuthnContextClassRef>
        </samlp:RequestedAuthnContext>
      </samlp:AuthnRequest>
    XML

    def setup
      # Do nothing
    end

    def teardown
      # Do nothing
    end

    def test_parse_undeflated
      request = Request.parse(AUTHN_REQUEST_XML)
      assert_equal AUTHN_REQUEST_XML, request.raw_request
    end

    def test_parse_deflated
      request = Request.parse(DEFLATED_AUTHN_REQUEST_XML)
      assert_equal AUTHN_REQUEST_XML, request.raw_request
    end

    def test_issuer_entity_id
      request = Request.parse(AUTHN_REQUEST_XML)
      assert_equal "https://idp.example.com/idp/shibboleth", request.issuer_entity_id
    end

    def test_needs_inflation
      strings_that_arent_deflated = %w[test these strings boi before i fall_apart slowlygentlythisishowalifeistaken]
      strings_that_arent_deflated.each do |word|
        assert !Request::Compression.needs_inflation?(word)
      end

      strings_that_are_deflated = strings_that_arent_deflated.map { |word| Request::Compression.deflate(word) }
      strings_that_are_deflated.each do |word|
        assert Request::Compression.needs_inflation?(word)
      end
    end

    def test_needs_decoding
      Faker::HTML.random
      strings_that_arent_encoded = 10.times.map { Faker::HTML.random }
      strings_that_arent_encoded.each do |word|
        pp Request::Encoding.decode(word)
        assert !Request::Encoding.needs_decoding?(word), "Expected #{word} to not need decoding"
      end

      strings_that_are_encoded = strings_that_arent_encoded.map { |word| Base64.encode64(word) }
      strings_that_are_encoded.each do |word|
        assert Request::Encoding.needs_decoding?(word), "Expected #{word} to need decoding"
      end
    end

    def test_deflate
      {
        "test" => "x\xDA+I-.\x01\x00\x04]\x01\xC1".dup.force_encoding("ASCII-8BIT"),
        "these" => "x\xDA+\xC9H-N\x05\x00\x06c\x02\x1A".dup.force_encoding("ASCII-8BIT"),
        "strings" => "x\xDA+.)\xCA\xCCK/\x06\x00\fM\x03\v".dup.force_encoding("ASCII-8BIT"),
      }.each do |inflated_word, deflated_word|
        assert_equal deflated_word, Request::Compression.deflate(inflated_word)
      end
    end

    def test_inflate
      {
        "test" => "x\xDA+I-.\x01\x00\x04]\x01\xC1".dup.force_encoding("ASCII-8BIT"),
        "these" => "x\xDA+\xC9H-N\x05\x00\x06c\x02\x1A".dup.force_encoding("ASCII-8BIT"),
        "strings" => "x\xDA+.)\xCA\xCCK/\x06\x00\fM\x03\v".dup.force_encoding("ASCII-8BIT"),
      }.each do |inflated_word, deflated_word|
        assert_equal inflated_word, Request::Compression.inflate(deflated_word)
      end
    end

    def test_decode
      %w[test these strings boi before i fall_apart slowlygentlythisishowalifeistaken].each do |word|
        encoded = Base64.encode64(word)
        decoded = Request::Encoding.decode(encoded)
        assert_equal word, decoded
      end
    end

    def test_verify_signature
      private_key = OpenSSL::PKey::RSA.new(2048)
      certificate = generate_self_signed_certificate(private_key)
      assert certificate.check_private_key private_key
      signed_request = Xmldsig::SignedDocument.new(UNSIGNED_XML_REQUEST_XML).sign(private_key)
      assert_kind_of String, signed_request
      req = Request.parse signed_request

      assert req.verify_signature(certificate)
    end
    
    private

      # Generates a self-signed certificate.
      #
      # @param private_key [OpenSSL::PKey]
      # @return [OpenSSL::X509::Certificate]
      def generate_self_signed_certificate(private_key)
        cert = OpenSSL::X509::Certificate.new
        cert.version = 2
        cert.subject = OpenSSL::X509::Name.new([
                                                 ["C", "US"],
                                                 ["ST", "California"],
                                                 ["L", "San Francisco"],
                                                 ["O", "Test Organization"],
                                                 ["CN", "test.example.com"]
                                               ])
        cert.issuer = cert.subject
        cert.public_key = private_key.public_key
        cert.not_before = 1.day.ago
        cert.not_after = 1.year.from_now

        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = cert
        ef.issuer_certificate = cert

        cert.add_extension(ef.create_extension("basicConstraints", "CA:TRUE", true))
        cert.add_extension(ef.create_extension("keyUsage", "keyCertSign, cRLSign", true))
        cert.add_extension(ef.create_extension("subjectKeyIdentifier", "hash"))

        cert
      end
  end
end
