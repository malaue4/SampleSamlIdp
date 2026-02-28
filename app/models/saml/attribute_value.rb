# frozen_string_literal: true

module Saml
  class AttributeValue
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ToXml

    attribute(:type, :string)
    attribute(:value)

    # @param [Nokogiri::XML::Node] attribute_element
    def self.parse(attribute_element)
      type = attribute_element.attribute_with_ns("type", "xsi")&.value
      attributes = {
        type: type,
        value: parse_attribute_value(attribute_element, xsi_type: type),
      }
      yield attributes if block_given?
      new(attributes)
    end

    # @param [Nokogiri::XML::Node] attribute_value_element
    def self.parse_attribute_value(attribute_value_element, xsi_type: "string")
      # Check for explicit nil
      return nil if attribute_value_element.attribute_with_ns("nil", "xsi")&.value == "true"

      # Parse based on type or fallback to text
      case xsi_type
      when /boolean/i
        attribute_value_element.text.strip.downcase == "true"
      when /int|long|short|byte/i
        attribute_value_element.text.strip.to_i
      when /decimal|double|float/i
        attribute_value_element.text.strip.to_f
      when /dateTime/i
        Time.parse(attribute_value_element.text.strip) rescue attribute_value_element.text.strip
      else
        # Default: return text content
        attribute_value_element.text
      end
    end

    private

      def xml_namespace
        { href: Namespaces::SAML, prefix: "saml" }
      end

      def xml_attributes
        { "xsi:type" => type, "xsi:nil" => value.nil? }.compact
      end

      def xml_content(builder)
        builder.text(value)
      end
  end
end
