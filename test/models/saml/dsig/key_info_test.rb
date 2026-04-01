# frozen_string_literal: true

require "test_helper"

module Saml
  module Dsig
    class KeyInfoTest < ActiveSupport::TestCase

      SAMPLE_XML = <<~XML
        <ds:KeyInfo Id="key1" xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
          <ds:KeyName>Main Key</ds:KeyName>
          <ds:KeyValue>
            <ds:RSAKeyValue>
              <ds:Modulus>AModulus</ds:Modulus>
              <ds:Exponent>AnExponent</ds:Exponent>
            </ds:RSAKeyValue>
          </ds:KeyValue>
          <ds:X509Data>
            <ds:X509Certificate>ACertificate</ds:X509Certificate>
          </ds:X509Data>
          <ds:MgmtData>SomeMgmtData</ds:MgmtData>
        </ds:KeyInfo>
      XML

      def setup
        element = Nokogiri::XML(SAMPLE_XML).at_xpath("//ds:KeyInfo", ds: Namespaces::DS)
        @key_info = KeyInfo.parse(element)
      end

      def test_parse
        assert_equal "key1", @key_info.id
        assert_equal ["Main Key"], @key_info.key_names
        assert_equal 1, @key_info.key_values.size
        assert_equal "AModulus", @key_info.key_values.first.rsa_key_value[:modulus]
        assert_equal "AnExponent", @key_info.key_values.first.rsa_key_value[:exponent]
        assert_equal 1, @key_info.x509_datas.size
        assert_equal "ACertificate", @key_info.x509_datas.first.elements.first[:value]
        assert_equal ["SomeMgmtData"], @key_info.mgmt_datas
      end

      def test_to_xml
        xml = @key_info.to_xml
        doc = Nokogiri::XML(xml)
        key_info = doc.at_xpath("//ds:KeyInfo", ds: Namespaces::DS)
        
        assert_equal "key1", key_info["Id"]
        assert_equal "Main Key", key_info.at_xpath("ds:KeyName", ds: Namespaces::DS).text
        assert_equal "AModulus", key_info.at_xpath("ds:KeyValue/ds:RSAKeyValue/ds:Modulus", ds: Namespaces::DS).text
        assert_equal "AnExponent", key_info.at_xpath("ds:KeyValue/ds:RSAKeyValue/ds:Exponent", ds: Namespaces::DS).text
        assert_equal "ACertificate", key_info.at_xpath("ds:X509Data/ds:X509Certificate", ds: Namespaces::DS).text
        assert_equal "SomeMgmtData", key_info.at_xpath("ds:MgmtData", ds: Namespaces::DS).text
      end

      def test_other_elements
        xml = <<~XML
          <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
            <ds:RetrievalMethod URI="#key1" Type="http://www.w3.org/2000/09/xmldsig#RSAKeyValue">
              <ds:Transforms>
                <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />
              </ds:Transforms>
            </ds:RetrievalMethod>
            <ds:PGPData>
              <ds:PGPKeyID>PGPID</ds:PGPKeyID>
            </ds:PGPData>
            <ds:SPKIData>
              <ds:SPKISexp>SPKISexpData</ds:SPKISexp>
            </ds:SPKIData>
          </ds:KeyInfo>
        XML
        element = Nokogiri::XML(xml).at_xpath("//ds:KeyInfo", ds: Namespaces::DS)
        key_info = KeyInfo.parse(element)

        assert_equal "#key1", key_info.retrieval_methods.first.uri
        assert_equal "http://www.w3.org/2000/09/xmldsig#enveloped-signature", key_info.retrieval_methods.first.transforms.first[:algorithm]
        assert_equal "PGPID", key_info.pgp_datas.first.pgp_key_id
        assert_equal "SPKISexpData", key_info.spki_datas.first.elements.first[:value]

        # Verify round-trip XML
        xml_out = key_info.to_xml
        doc = Nokogiri::XML(xml_out)
        assert doc.at_xpath("//ds:RetrievalMethod[@URI='#key1']", ds: Namespaces::DS)
        assert doc.at_xpath("//ds:PGPData/ds:PGPKeyID", ds: Namespaces::DS)
        assert_equal "SPKISexpData", doc.at_xpath("//ds:SPKIData/ds:SPKISexp", ds: Namespaces::DS).text
      end
    end
  end
end
