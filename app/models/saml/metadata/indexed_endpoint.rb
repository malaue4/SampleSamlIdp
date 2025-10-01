# frozen_string_literal: true

module Saml
  module Metadata
    class IndexedEndpoint < Endpoint

      attr_accessor(
        :index,
        :default
      )


      # @param [Nokogiri::XML::Node] indexed_endpoint_element
      def self.parse(indexed_endpoint_element)
        super(indexed_endpoint_element) do |attrs|
          attrs.merge!(
            index: indexed_endpoint_element.attribute("index")&.value.to_i,
            default: indexed_endpoint_element.attribute("isDefault")&.value == "true"
          )
          yield attrs if block_given?
        end
      end
    end
  end
end
