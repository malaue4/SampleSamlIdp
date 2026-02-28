# frozen_string_literal: true

module Saml
  class Attribute
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ToXml

    attribute(:name)
    attribute(:name_format, default: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri")
    attribute(:friendly_name)
    attribute(:attribute_value)

    # @param [Nokogiri::XML::Node] attribute_element
    def self.parse(attribute_element)
      attributes = {
        name: attribute_element.attribute("Name")&.value,
        name_format: attribute_element.attribute("NameFormat")&.value,
        friendly_name: attribute_element.attribute("FriendlyName")&.value,
        attribute_value: attribute_element
          .xpath("saml:AttributeValue", "saml" => Namespaces::SAML)
          .map { |av| AttributeValue.parse(av) }
          .then { |values| values.size > 1 ? values : values.first },
      }
      yield attributes if block_given?
      new(attributes)
    end

    private

      def xml_namespace
        { href: Namespaces::SAML, prefix: "saml" }
      end

      def xml_attributes
        { Name: name, NameFormat: name_format, FriendlyName: friendly_name }.compact
      end

      def xml_content(builder)
        Array(attribute_value).each { |av| av.build_xml(builder) }
      end
  end
end
