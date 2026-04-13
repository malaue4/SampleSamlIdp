# frozen_string_literal: true

module Saml
  module Dsig
    class Reference
      include ActiveModel::Model
      include ActiveModel::Attributes
      include LazyAttributes
      include ToXml

      attribute :id, :string
      lazy_attribute(:id) { reference_element&.attribute("Id")&.value }
      attribute :uri, :string
      lazy_attribute(:uri) { reference_element&.attribute("URI")&.value }
      attribute :type, :string
      lazy_attribute(:type) { reference_element&.attribute("Type")&.value }

      attribute :transforms
      lazy_attribute(:transforms) { parse_transforms }
      attribute :digest_method, :string
      lazy_attribute(:digest_method) { reference_element&.at_xpath("ds:DigestMethod", ds: Namespaces::DS)&.attribute("Algorithm")&.value }
      attribute :digest_value, :string
      lazy_attribute(:digest_value) { reference_element&.at_xpath("ds:DigestValue", ds: Namespaces::DS)&.text }

      def self.parse(reference_element)
        new.tap do |instance|
          instance.instance_variable_set(:@reference_element, reference_element)
        end
      end

      private

        attr_reader :reference_element

        def parse_transforms
          reference_element&.xpath("ds:Transforms/ds:Transform", ds: Namespaces::DS)&.map do |el|
            Transform.parse(el)
          end || []
        end

        def xml_namespace
          { href: Namespaces::DS, prefix: "ds" }
        end

        def xml_attributes
          { Id: id, URI: uri, Type: type }.compact
        end

        def xml_content(builder)
          if transforms.any?
            builder.Transforms do |tr|
              transforms.each { |t| t.build_xml(tr) }
            end
          end

          builder.DigestMethod(Algorithm: digest_method) if digest_method
          builder.DigestValue digest_value if digest_value
        end
    end
  end
end
