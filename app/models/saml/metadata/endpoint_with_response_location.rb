# frozen_string_literal: true

module Saml
  module Metadata
    # Base class for SAML metadata endpoints that include a ResponseLocation attribute.
    class EndpointWithResponseLocation < EndpointWithoutResponseLocation
      # @!attribute [rw] response_location
      #   @return [String] the URI reference identifying the location for SAML response messages
      attribute :response_location, :string
      lazy_attribute(:response_location) { endpoint_element&.attribute("ResponseLocation")&.value }

      private

        def xml_attributes
          super.merge(
            ResponseLocation: response_location,
          ).compact
        end
    end
  end
end
