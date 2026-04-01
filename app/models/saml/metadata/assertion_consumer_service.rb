# frozen_string_literal: true

module Saml
  module Metadata
    class AssertionConsumerService < EndpointWithResponseLocation
      include IndexedEndpoint
    end
  end
end
