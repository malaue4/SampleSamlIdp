# frozen_string_literal: true

module Saml
  module Dsig
    class RetrievalMethod
      include ActiveModel::Model
      include ActiveModel::Attributes
      include LazyAttributes
      include ToXml

      attribute :uri, :string
      lazy_attribute(:uri) { element&.attribute("URI")&.value }
      attribute :type, :string
      lazy_attribute(:type) { element&.attribute("Type")&.value }
      attribute :transforms
      lazy_attribute(:transforms) { parse_transforms }

      def self.parse(element)
        new.tap do |instance|
          instance.instance_variable_set(:@element, element)
        end
      end

      private

        attr_reader :element

        def parse_transforms
          # Assuming there's a Transform class or similar logic in the project.
          # For now, let's keep it simple or see if we need a Transform model.
          # XML schema says: <element ref="ds:Transforms" minOccurs="0"/>
          element.xpath("ds:Transforms/ds:Transform", ds: Namespaces::DS).map do |it|
            {
              algorithm: it.attribute("Algorithm")&.value,
              content: it.children.to_xml
            }
          end
        end

        def xml_namespace
          { href: Namespaces::DS, prefix: "ds" }
        end

        def xml_attributes
          { URI: uri, Type: type }.compact
        end

        def xml_content(builder)
          if transforms.present?
            builder.Transforms do |transforms_builder|
              transforms.each do |transform|
                transforms_builder.Transform(Algorithm: transform[:algorithm]) do |t|
                  t << transform[:content]
                end
              end
            end
          end
        end
    end
  end
end
