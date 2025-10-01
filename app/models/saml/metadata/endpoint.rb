# frozen_string_literal: true

module Saml
  module Metadata
    class Endpoint
      include ActiveModel::Model

      attr_accessor(
        :binding,
        :location,
        :response_location,
      )


      # @param [Nokogiri::XML::Node] endpoint_element
      def self.parse(endpoint_element)
        attributes = {
          binding: endpoint_element.attribute("Binding")&.value,
          location: endpoint_element.attribute("Location")&.value,
          response_location: endpoint_element.attribute("ResponseLocation")&.value,
        }
        yield attributes if block_given?
        new(attributes)
      end
    end
  end
end
