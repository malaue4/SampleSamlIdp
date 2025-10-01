# frozen_string_literal: true

module Saml
  class AuthnRequest < Request
    POST_BINDING = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
    REDIRECT_BINDING = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-REDIRECT"

    validates :assertion_consumer_service_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_nil: true }
    validates :passive?, absence: { if: :force_authn? }
    validates :force_authn?, absence: { if: :passive? }
    validates :protocol_binding, inclusion: { in: [ POST_BINDING, REDIRECT_BINDING ], allow_blank: true }
    validates :assertion_consumer_service_index, inclusion: { in: :assertion_consumer_service_indices }, allow_nil: true
    validates :attribute_consuming_service_index, inclusion: { in: :attribute_consuming_service_indices }, allow_nil: true

    validate if: :conditions do
      if conditions[:one_time_use]
        # Validate that this request hasn't been sent before... I thought that was the default behavior?
        # TODO: Add model for storing received requests, and validate that this request hasn't been received before.
        if false # ReceivedRequests.exists?(request_id: id)
          errors.add(:id, :taken)
        end
      end
      if conditions[:not_before].present? && conditions[:not_before].to_time.future?
        errors.add(:conditions, :not_before, message: "message has been received too soon?")
      end
      if conditions[:not_on_or_after].present? && !conditions[:not_on_or_after].to_time.future?
        errors.add(:conditions, :not_on_or_after, message: "message has been received too late")
      end
      if conditions[:audience_restrictions] && conditions[:audience_restrictions].exclude?(metadata.entity_id)
        errors.add(:conditions, :audience_restrictions, message: "this request wasn't meant for us")
      end
    end

    validate do
      if assertion_consumer_service_index && protocol_binding
        Rails.logger.warn { "Assertion consumer service index and protocol binding specified at the same time. That's weird." }
      end

      if assertion_consumer_service_index && assertion_consumer_service_url
        Rails.logger.warn { "Assertion consumer service index and URL specified at the same time. That's kinda weird." }
      end
    end

      def force_authn?
        @force_authn ||= request_element.attribute("ForceAuthn")&.value == "true"
      end

      def passive?
        @passive ||= request_element.attribute("IsPassive")&.value == "true"
      end

      def protocol_binding
        @protocol_binding ||= request_element.attribute("ProtocolBinding")&.value
      end

      def assertion_consumer_service_index
        @assertion_consumer_service_index ||= request_element.attribute("AssertionConsumerServiceIndex")&.value&.to_i
      end

      def assertion_consumer_service_url
        @assertion_consumer_service_url ||= request_element.attribute("AssertionConsumerServiceURL")&.value
      end

      def attribute_consuming_service_index
        @attribute_consuming_service_index ||= request_element.attribute("AttributeConsumingServiceIndex")&.value&.to_i
      end

      def provider_name
        @provider_name ||= request_element.attribute("ProviderName")&.value
      end

      def subject_element
        @subject_element ||= request_element.at_xpath("saml:Subject", "saml" => Namespaces::SAML)
      end

      def subject
        return unless subject_element

        @subject ||= {
          name_id: subject_element.at_xpath("saml:NameID", "saml" => Namespaces::SAML)
            &.then { |name_id_element| NameId.parse(name_id_element) },
          subject_confirmations: subject_element
            .xpath("saml:SubjectConfirmation", "saml" => Namespaces::SAML)
            .map { |subject_confirmation_element| SubjectConfirmation.parse(subject_confirmation_element) },
        }
      end

      def name_id_policy_element
        @name_id_policy_element ||= request_element.at_xpath("samlp:NameIDPolicy", "samlp" => Namespaces::SAMLP)
      end

      def name_id_policy
        return if name_id_policy_element.nil?

        @name_id_policy ||= {
          format: name_id_policy_element&.attribute("Format")&.value,
          sp_name_qualifier: name_id_policy_element&.attribute("SPNameQualifier")&.value,
          allow_create: name_id_policy_element&.attribute("AllowCreate")&.value == "true"
        }
      end

      def conditions_element
        @conditions_element ||= request_element.at_xpath("saml:Conditions", "saml" => Namespaces::SAML)
      end

    # Returns conditions extracted from the SAML request, including audience restrictions,
    # one-time use indications, proxy restrictions, and time constraints. Conditions are
    # parsed from the `<saml:Conditions>` element in the SAML request.
    #
    # - `audience_restrictions`: A list of audiences extracted from `<saml:AudienceRestriction>`.
    # - `one_time_use`: A boolean indicating the presence of the `<saml:OneTimeUse>` element, used to
    #   enforce that the assertion can only be used once.
    # - `proxy_restriction`: Currently an empty array, intended for handling `<ProxyRestriction>` elements
    #   in the future.
    # - `not_before`: The `NotBefore` timestamp, extracted to indicate the earliest valid time for the assertion.
    # - `not_on_or_after`: The `NotOnOrAfter` timestamp, extracted to indicate the latest valid time for the assertion.
    #
    # The method caches the parsed conditions for future use.
    #
    # @return [Hash] A hash representing the parsed conditions.
      def conditions
        return if conditions_element.nil?

        @conditions ||= {
          audience_restrictions: conditions_element
            .xpath("saml:AudienceRestriction/saml:Audience", "saml" => Namespaces::SAML)
            .map(&:text)
            .presence,
          one_time_use: conditions_element.at_xpath("saml:OneTimeUse", "saml" => Namespaces::SAML).present?,
          proxy_restrictions: [].presence, # TODO: It looks like this: `<ProxyRestriction Count="2"><Audience>https://www.example.com/sp</Audience></ProxyRestriction>`
          not_before: conditions_element&.attribute("NotBefore")&.value,
          not_on_or_after: conditions_element&.attribute("NotOnOrAfter")&.value,
        }.compact
      end

      def requested_authn_context_element
        @requested_authn_context_element ||= request_element.at_xpath("samlp:RequestedAuthnContext", "samlp" => Namespaces::SAMLP)
      end

      def requested_authn_context
        return if requested_authn_context_element.nil?

        @requested_authn_context ||= {
          class_refs: requested_authn_context_element
            .xpath("saml:AuthnContextClassRef", "saml" => Namespaces::SAML).map(&:text).presence,
          decl_refs: requested_authn_context_element
            .xpath("saml:AuthnContextDeclRef", "saml" => Namespaces::SAML).map(&:text).presence,
          comparison: requested_authn_context_element.attribute("Comparison")&.value
        }.compact
      end

      def scoping_element
        @scoping_element ||= request_element.at_xpath("samlp:Scoping", "samlp" => Namespaces::SAMLP)
      end

    # Extracts and returns the scoping information from the SAML request, if available. Scoping information
    # is parsed from the `<samlp:Scoping>` element and may include details such as proxying restrictions
    # and a list of acceptable Identity Providers (IDPs).
    #
    # - `proxy_count`: An integer representing the maximum number of proxies allowed, extracted from the
    #   `ProxyCount` attribute of the `<samlp:Scoping>` element. Returns nil if the attribute is not specified.
    # - `idp_list`: A hash containing details about acceptable IDPs, parsed from the `<samlp:IDPList>` element:
    #   - `entries`: An array of hashes, each representing an IDP entry from the `<samlp:IDPEntry>` elements.
    #     Each hash includes:
    #     - `provider_id`: The ProviderID of the IDP entry.
    #     - `name`: The Name of the IDP entry, if specified.
    #     - `location`: The Loc (location) of the IDP entry, if specified.
    #   - `get_complete`: A string representing the value of the `<samlp:GetComplete>` element, indicating
    #     a URI from which a complete list of acceptable IDPs can be retrieved.
    #
    # The method caches the parsed scoping information for future use.
    #
    # @return [Hash] A hash representing the parsed scoping information.
    def scoping
        return if scoping_element.nil?

        @scoping ||= {
          proxy_count: scoping_element.attribute("ProxyCount")&.value&.to_i,
          idp_list: {
            entries: scoping_element.xpath("samlp:IDPList/samlp:IDPEntry", "samlp" => Namespaces::SAMLP).map do |entry|
              {
                provider_id: entry.attribute("ProviderID")&.value,
                name: entry.attribute("Name")&.value,
                location: entry.attribute("Loc")&.value,
              }.compact
            end,
            get_complete: scoping_element.at_xpath("samlp:IDPList/samlp:GetComplete", "samlp" => Namespaces::SAMLP)&.value
          }.compact
        }.compact
      end

    private

      def assertion_consumer_service_indices
        []
      end

      def attribute_consuming_service_indices
        []
      end
  end
end
