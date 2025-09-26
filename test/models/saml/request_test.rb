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

    SIGNED_XML_REQUEST_XML = <<~XML
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
              <ds:DigestValue>yJN6cXUwQxTmMEsPesBP2NkqYFI=</ds:DigestValue>
            </ds:Reference>
          </ds:SignedInfo>
          <ds:SignatureValue>g5eM9yPnKsmmE/Kh2qS7nfK8HoF6yHrAdNQxh70kh8pRI4KaNbYNOL9sF8F57Yd+jO6iNga8nnbwhbATKGXIZOJJSugXGAMRyZsj/rqngwTJk5KmujbqouR1SLFsbo7Iuwze933EgefBbAE4JRI7V2aD9YgmB3socPqAi2Qf97E=</ds:SignatureValue>
          <ds:KeyInfo>
            <ds:X509Data>
              <ds:X509Certificate>MIICajCCAdOgAwIBAgIBADANBgkqhkiG9w0BAQQFADBSMQswCQYDVQQGEwJ1czETMBEGA1UECAwKQ2FsaWZvcm5pYTEVMBMGA1UECgwMT25lbG9naW4gSW5jMRcwFQYDVQQDDA5zcC5leGFtcGxlLmNvbTAeFw0xNDA3MTcwMDI5MjdaFw0xNTA3MTcwMDI5MjdaMFIxCzAJBgNVBAYTAnVzMRMwEQYDVQQIDApDYWxpZm9ybmlhMRUwEwYDVQQKDAxPbmVsb2dpbiBJbmMxFzAVBgNVBAMMDnNwLmV4YW1wbGUuY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7vU/6R/OBA6BKsZH4L2bIQ2cqBO7/aMfPjUPJPSn59d/f0aRqSC58YYrPuQODydUABiCknOn9yV0fEYm4bNvfjroTEd8bDlqo5oAXAUAI8XHPppJNz7pxbhZW0u35q45PJzGM9nCv9bglDQYJLby1ZUdHsSiDIpMbGgf/ZrxqawIDAQABo1AwTjAdBgNVHQ4EFgQU3s2NEpYx7wH6bq7xJFKa46jBDf4wHwYDVR0jBBgwFoAU3s2NEpYx7wH6bq7xJFKa46jBDf4wDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQQFAAOBgQCPsNO2FG+zmk5miXEswAs30E14rBJpe/64FBpM1rPzOleexvMgZlr0/smF3P5TWb7H8Fy5kEiByxMjaQmml/nQx6qgVVzdhaTANpIE1ywEzVJlhdvw4hmRuEKYqTaFMLez0sRL79LUeDxPWw7Mj9FkpRYT+kAGiFomHop1nErV6Q==</ds:X509Certificate>
            </ds:X509Data>
          </ds:KeyInfo>
        </ds:Signature>
        <samlp:NameIDPolicy Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress" AllowCreate="true"/>
        <samlp:RequestedAuthnContext Comparison="exact">
          <saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</saml:AuthnContextClassRef>
        </samlp:RequestedAuthnContext>
      </samlp:AuthnRequest>
          XML

    CERTIFICATE = <<CERTIFICATE
-----BEGIN CERTIFICATE-----
MIICajCCAdOgAwIBAgIBADANBgkqhkiG9w0BAQQFADBSMQswCQYDVQQGEwJ1czETMBEGA1UECAwKQ2FsaWZvcm5pYTEVMBMGA1UECgwMT25lbG9naW4gSW5jMRcwFQYDVQQDDA5zcC5leGFtcGxlLmNvbTAeFw0xNDA3MTcwMDI5MjdaFw0xNTA3MTcwMDI5MjdaMFIxCzAJBgNVBAYTAnVzMRMwEQYDVQQIDApDYWxpZm9ybmlhMRUwEwYDVQQKDAxPbmVsb2dpbiBJbmMxFzAVBgNVBAMMDnNwLmV4YW1wbGUuY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7vU/6R/OBA6BKsZH4L2bIQ2cqBO7/aMfPjUPJPSn59d/f0aRqSC58YYrPuQODydUABiCknOn9yV0fEYm4bNvfjroTEd8bDlqo5oAXAUAI8XHPppJNz7pxbhZW0u35q45PJzGM9nCv9bglDQYJLby1ZUdHsSiDIpMbGgf/ZrxqawIDAQABo1AwTjAdBgNVHQ4EFgQU3s2NEpYx7wH6bq7xJFKa46jBDf4wHwYDVR0jBBgwFoAU3s2NEpYx7wH6bq7xJFKa46jBDf4wDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQQFAAOBgQCPsNO2FG+zmk5miXEswAs30E14rBJpe/64FBpM1rPzOleexvMgZlr0/smF3P5TWb7H8Fy5kEiByxMjaQmml/nQx6qgVVzdhaTANpIE1ywEzVJlhdvw4hmRuEKYqTaFMLez0sRL79LUeDxPWw7Mj9FkpRYT+kAGiFomHop1nErV6Q==
-----END CERTIFICATE-----
CERTIFICATE

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
      assert_equal UNDEFLATED_AUTHN_REQUEST_XML, request.raw_request
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
      req = Request.parse SIGNED_XML_REQUEST_XML

      assert req.verify_signature(OpenSSL::X509::Certificate.new(CERTIFICATE))
    end
  end
end
