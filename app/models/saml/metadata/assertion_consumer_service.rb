# frozen_string_literal: true

module Saml
  module Metadata
    # The AssertionConsumerService (ACS) endpoint is responsible for receiving and processing
    # SAML assertions sent by the Identity Provider (IdP) to the Service Provider (SP).
    # It is where the IdP redirects the user's browser after successful authentication.
    class AssertionConsumerService < EndpointWithResponseLocation
      include IndexedEndpoint
    end
  end
end
