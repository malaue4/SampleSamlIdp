# frozen_string_literal: true

module Saml
  module Metadata
    # The AssertionIDRequestService (AIRS) endpoint is used to retrieve specific
    # SAML assertions by their ID, allowing an entity to query for assertions
    # that it may have missed or that it needs to re-fetch.
    class AssertionIdRequestService < EndpointWithoutResponseLocation
    end
  end
end
