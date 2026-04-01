# frozen_string_literal: true

module Saml
  module Metadata
    # Shared logic for indexed SAML metadata endpoints.
    module IndexedEndpoint
      extend ActiveSupport::Concern

      included do
        # @!attribute [rw] index
        #   @return [Integer] the unique index for the endpoint
        attribute :index, :integer
        lazy_attribute(:index) { endpoint_element&.attribute("index")&.value&.to_i }
        # @!attribute [rw] default
        #   @return [Boolean] whether the endpoint is the default one
        attribute :default, :boolean
        lazy_attribute(:default) { endpoint_element&.attribute("isDefault")&.value == "true" }
      end

      private

        def xml_attributes
          super.merge(
            index: index,
            isDefault: default
          ).compact
        end
    end
  end
end
