# frozen_string_literal: true

module Saml
  module Metadata
    class RequestedAttribute < Attribute

      attribute :required, :boolean, default: false

      def self.parse(name_id_element)
        super(name_id_element) do |attributes|
          attributes[:required] = name_id_element.attribute("isRequired")&.value == "true"
        end
      end

      private

        def xml_attributes
          super.merge(isRequired: required)
        end

        def xml_namespace
          "md"
        end
    end
  end
end
