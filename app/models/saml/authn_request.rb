# frozen_string_literal: true

module Saml
  class AuthnRequest < Request
    POST_BINDING = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
    REDIRECT_BINDING = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"

    attribute :force_authn, :boolean
    lazy_attribute(:force_authn) { request_element.attribute("ForceAuthn")&.value == "true" }
    attribute :passive, :boolean
    lazy_attribute(:passive) { request_element.attribute("IsPassive")&.value == "true" }
    attribute :protocol_binding, default: POST_BINDING
    lazy_attribute(:protocol_binding) { request_element.attribute("ProtocolBinding")&.value }
    attribute :assertion_consumer_service_index, :integer
    lazy_attribute(:assertion_consumer_service_index) { request_element.attribute("AssertionConsumerServiceIndex")&.value&.to_i }
    attribute :assertion_consumer_service_url, :string
    lazy_attribute(:assertion_consumer_service_url) { request_element.attribute("AssertionConsumerServiceURL")&.value }
    attribute :attribute_consuming_service_index, :integer
    lazy_attribute(:attribute_consuming_service_index) { request_element.attribute("AttributeConsumingServiceIndex")&.value&.to_i }
    attribute :provider_name, :string
    lazy_attribute(:provider_name) { request_element.attribute("ProviderName")&.value }
    attribute :subject
    lazy_attribute(:subject) { parse_subject }
    attribute :name_id_policy
    lazy_attribute(:name_id_policy) { parse_name_id_policy }
    attribute :conditions
    lazy_attribute(:conditions) { parse_conditions }
    attribute :requested_authn_context
    lazy_attribute(:requested_authn_context) { parse_requested_authn_context }
    attribute :scoping
    lazy_attribute(:scoping) { parse_scoping }

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
      force_authn
    end

    def passive?
      passive
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

    def parse_subject
      return unless subject_element

      @subject ||= Subject.parse(subject_element)
    end

    def name_id_policy_element
      @name_id_policy_element ||= request_element.at_xpath("samlp:NameIDPolicy", "samlp" => Namespaces::SAMLP)
    end


    # TODO: Make it its own class?
    def parse_name_id_policy
      return if name_id_policy_element.nil?

      @name_id_policy ||= {
        format: name_id_policy_element&.attribute("Format")&.value,
        sp_name_qualifier: name_id_policy_element&.attribute("SPNameQualifier")&.value,
        allow_create: name_id_policy_element&.attribute("AllowCreate")&.value == "true"
      }
    end

    def parse_conditions
      conditions_element = request_element.at_xpath("saml:Conditions", "saml" => Namespaces::SAML)
      return if conditions_element.nil?

      Conditions.parse(conditions_element)
    end

    def requested_authn_context_element
      @requested_authn_context_element ||= request_element.at_xpath("samlp:RequestedAuthnContext", "samlp" => Namespaces::SAMLP)
    end


    # TODO: Make it its own class?
    def parse_requested_authn_context
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
    # TODO: Make it its own class?
    #
    # @return [Hash] A hash representing the parsed scoping information.
    def parse_scoping
      return Rails.logger.debug { "Scoping element is nil, skipping parsing" } if scoping_element.nil?
      Rails.logger.debug { "The scoping element is" + scoping_element.inspect }
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
