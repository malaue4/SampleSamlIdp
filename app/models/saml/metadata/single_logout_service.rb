module Saml
  module Metadata
    # The SingleLogoutService (SLO) endpoint is used to propagate logout requests and responses
    # between the Service Provider (SP) and the Identity Provider (IdP), allowing for
    # a session termination across all participating entities in the SAML circle.
    class SingleLogoutService < EndpointWithResponseLocation
    end
  end
end
