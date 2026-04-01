module Saml
  module Metadata
    class SingleSignOnService < Endpoint

      validates :response_location, absence: true

      private

        # The SAML metadata specification (lines 690-693) explicitly states that
        # ResponseLocation MUST be omitted on SingleSignOnService endpoints.
        def xml_attributes
          super.except(:ResponseLocation)
        end
    end
  end
end
