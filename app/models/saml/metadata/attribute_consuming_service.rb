# frozen_string_literal: true

module Saml
  module Metadata
    class AttributeConsumingService
      include ActiveModel::Model

      attr_accessor(
        :service_name,
        :service_description,
        :requested_attributes,
        :index,
        :default
      )


      # @param [Nokogiri::XML::Node] attribute_consuming_service_element
      def self.parse(attribute_consuming_service_element)
        new(
          service_name: attribute_consuming_service_element
            .xpath("md:ServiceName", "md" => Namespaces::MD)
            .to_h { |sn| [sn.attribute_with_ns("lang", Namespaces::XML)&.value, sn.text] },
          service_description: attribute_consuming_service_element
            .xpath("md:ServiceDescription", "md" => Namespaces::MD)
            .to_h { |sn| [sn.attribute_with_ns("lang", Namespaces::XML)&.value, sn.text] },
          requested_attributes: attribute_consuming_service_element
            .xpath("md:RequestedAttribute", "md" => Namespaces::MD)
            .map { |rae| RequestedAttribute.parse(rae) },
          index: attribute_consuming_service_element.attribute("index")&.value.to_i,
          default: attribute_consuming_service_element.attribute("isDefault")&.value == "true"
        )
      end

      # @param [Nokogiri::XML::Builder] builder
      def to_xml(builder)
        builder.AttributeConsumingService do

        end
      end
    end
  end
end
