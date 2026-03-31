# frozen_string_literal: true

module Saml
  module Metadata
    class IndexedEndpoint < Endpoint

      attribute :index, :integer
      lazy_attribute(:index) { endpoint_element&.attribute("index")&.value&.to_i }
      attribute :default, :boolean
      lazy_attribute(:default) { endpoint_element&.attribute("isDefault")&.value == "true" }

      private

        def xml_attributes
          super.merge!(
            index: index,
            isDefault: default
          ).compact
        end
    end
  end
end
