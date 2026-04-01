# frozen_string_literal: true

module Saml
  module Metadata
    class EndpointWithResponseLocation < EndpointWithoutResponseLocation
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
