# frozen_string_literal: true

module Saml
  module Dsig
    class Signature
      include ActiveModel::Model
      include ActiveModel::Attributes
      include LazyAttributes
      include ToXml

      SIGNATURE_ALGORITHMS = {
        rsa_sha1: "http://www.w3.org/2000/09/xmldsig#rsa-sha1",
        rsa_sha256: "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256",
        rsa_sha384: "http://www.w3.org/2001/04/xmldsig-more#rsa-sha384",
        rsa_sha512: "http://www.w3.org/2001/04/xmldsig-more#rsa-sha512",
        dsa_sha1: "http://www.w3.org/2000/09/xmldsig#dsa-sha1",
        dsa_sha256: "http://www.w3.org/2009/xmldsig11#dsa-sha256"
      }.freeze

      attribute :id, :string
      lazy_attribute(:id) { signature_element&.attribute("Id")&.value }
      attribute :signed_info
      lazy_attribute(:signed_info) { signed_info_element.present? ? SignedInfo.parse(signed_info_element) : nil }
      attribute :signature_value
      lazy_attribute(:signature_value) { signature_element&.at_xpath("ds:SignatureValue", ds: Namespaces::DS)&.text }
      attribute :key_info
      lazy_attribute(:key_info) { key_info_element.present? ? KeyInfo.parse(key_info_element) : nil }
      attribute :objects
      lazy_attribute(:objects) { signature_element&.xpath("ds:Object", ds: Namespaces::DS) || [] }

      def self.parse(signature_element)
        new.tap do |instance|
          instance.instance_variable_set(:@signature_element, signature_element)
        end
      end

      def self.prepare_for_signing(reference_uri, signature_algorithm: :rsa_sha1)
        new.tap do |instance|
          instance.signed_info = SignedInfo.new(
            canonicalization_method: "http://www.w3.org/TR/2001/REC-xml-c14n-20010315",
            signature_method: SIGNATURE_ALGORITHMS.fetch(signature_algorithm),
            references: [Reference.new(uri: "##{reference_uri}").tap do |it|
              it.transforms = [Transform.enveloped_signature]
              it.digest_method = "http://www.w3.org/2001/04/xmlenc#sha256"
              it.digest_value = ""
            end])
          instance.signature_value = ""
        end
      end

      private

        attr_reader :signature_element

        def signed_info_element
          @signed_info_element ||= signature_element&.at_xpath("ds:SignedInfo", ds: Namespaces::DS)
        end

        def key_info_element
          @key_info_element ||= signature_element&.at_xpath("ds:KeyInfo", ds: Namespaces::DS)
        end

        def xml_namespace
          { href: Namespaces::DS, prefix: "ds" }
        end

        def xml_attributes
          { Id: id }.compact
        end

        def xml_content(builder)
          signed_info&.build_xml(builder)
          builder.SignatureValue signature_value if signature_value
          key_info&.build_xml(builder)
          objects.each { |obj| builder << obj.to_xml }
        end
    end
  end
end
