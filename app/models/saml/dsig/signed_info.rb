# frozen_string_literal: true

module Saml
  module Dsig
    class SignedInfo
      include ActiveModel::Model
      include ActiveModel::Attributes
      include LazyAttributes
      include ToXml

      attribute :id, :string
      lazy_attribute(:id) { signed_info_element&.attribute("Id")&.value }
      attribute :canonicalization_method, :string
      lazy_attribute(:canonicalization_method) { signed_info_element&.at_xpath("ds:CanonicalizationMethod", ds: Namespaces::DS)&.attribute("Algorithm")&.value }
      attribute :signature_method, :string
      lazy_attribute(:signature_method) { signed_info_element&.at_xpath("ds:SignatureMethod", ds: Namespaces::DS)&.attribute("Algorithm")&.value }
      attribute :references
      lazy_attribute(:references) { parse_references }

      def self.parse(signed_info_element)
        new.tap do |instance|
          instance.instance_variable_set(:@signed_info_element, signed_info_element)
        end
      end

      private

        attr_reader :signed_info_element

        def parse_references
          signed_info_element&.xpath("ds:Reference", ds: Namespaces::DS)&.map do |el|
            Reference.parse(el)
          end || []
        end

        def xml_namespace
          { href: Namespaces::DS, prefix: "ds" }
        end

        def xml_attributes
          { Id: id }.compact
        end

        def xml_content(builder)
          builder.CanonicalizationMethod(Algorithm: canonicalization_method) if canonicalization_method
          builder.SignatureMethod(Algorithm: signature_method) if signature_method
          references.each { |ref| ref.build_xml(builder) }
        end
    end
  end
end
