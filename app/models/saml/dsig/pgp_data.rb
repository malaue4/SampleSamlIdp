# frozen_string_literal: true

module Saml
  module Dsig
    class PGPData
      include ActiveModel::Model
      include ActiveModel::Attributes
      include LazyAttributes
      include ToXml

      attribute :pgp_key_id, :string
      lazy_attribute(:pgp_key_id) { element&.at_xpath("ds:PGPKeyID", ds: Namespaces::DS)&.text }
      attribute :pgp_key_packet, :string
      lazy_attribute(:pgp_key_packet) { element&.at_xpath("ds:PGPKeyPacket", ds: Namespaces::DS)&.text }
      attribute :other_elements
      lazy_attribute(:other_elements) { parse_other_elements }

      def self.parse(element)
        new.tap do |instance|
          instance.instance_variable_set(:@element, element)
        end
      end

      private

        attr_reader :element

        def parse_other_elements
          element.xpath("*[not(self::ds:PGPKeyID or self::ds:PGPKeyPacket)]", ds: Namespaces::DS)
        end

        def xml_namespace
          { href: Namespaces::DS, prefix: "ds" }
        end

        def xml_content(builder)
          builder.PGPKeyID pgp_key_id if pgp_key_id
          builder.PGPKeyPacket pgp_key_packet if pgp_key_packet
          other_elements.each { |el| builder << el.to_xml }
        end
    end
  end
end
