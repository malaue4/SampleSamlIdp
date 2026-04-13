# frozen_string_literal: true

module Saml
  module Dsig
    class Transform
      include ActiveModel::Model
      include ActiveModel::Attributes
      include LazyAttributes
      include ToXml

      attribute :algorithm, :string
      lazy_attribute(:algorithm) { transform_element&.attribute("Algorithm")&.value }
      attribute :content
      lazy_attribute(:content) { transform_element&.children&.to_xml }

      def self.parse(transform_element)
        new.tap do |instance|
          instance.instance_variable_set(:@transform_element, transform_element)
        end
      end

      def self.enveloped_signature
        new(algorithm: "http://www.w3.org/2000/09/xmldsig#enveloped-signature")
      end

      private

        attr_reader :transform_element

        def xml_namespace
          { href: Namespaces::DS, prefix: "ds" }
        end

        def xml_attributes
          { Algorithm: algorithm }.compact
        end

        def xml_content(builder)
          builder << content if content
        end
    end
  end
end
