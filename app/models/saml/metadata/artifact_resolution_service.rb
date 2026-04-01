# frozen_string_literal: true

module Saml
  module Metadata
    # The ArtifactResolutionService (ARS) endpoint is used to exchange a SAML artifact
    # for the corresponding SAML message. This is part of the Artifact Resolution Profile,
    # where the SAML message is not sent directly via the browser but retrieved out-of-band.
    class ArtifactResolutionService < EndpointWithoutResponseLocation
      include IndexedEndpoint
    end

  end
end
