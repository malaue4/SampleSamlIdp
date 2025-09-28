# frozen_string_literal: true

module Saml
  class Attribute
    include ActiveModel::Model

    attr_accessor :name, :name_format, :friendly_name, :attribute_value

    # @param [Nokogiri::XML::Node] attribute_element
    def self.parse(attribute_element)
      attributes = {
        name: attribute_element.attribute("Name")&.value,
        name_format: attribute_element.attribute("NameFormat")&.value,
        friendly_name: attribute_element.attribute("FriendlyName")&.value,
        attribute_value: attribute_element
          .xpath("saml:AttributeValue", "saml" => Namespaces::SAML)
          .map { |av| parse_attribute_value(av) }
          .then { |values| values.size > 1 ? values : values.first },
      }
      yield attributes if block_given?
      new(attributes)
    end

    # @param [Nokogiri::XML::Node] attribute_value_element
    def self.parse_attribute_value(attribute_value_element)
      # Check for explicit nil
      return nil if attribute_value_element.attribute("xsi:nil")&.value == "true"

      # Get the type information
      xsi_type = attribute_value_element.attribute("xsi:type")&.value

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
  end
end
