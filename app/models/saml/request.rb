# frozen_string_literal: true

module Saml
  class Request
    attr_reader :raw_request

    def self.parse(maybe_encoded_request)
      decoded_request = Encoding.decode_if_needed(maybe_encoded_request)
      raw_request = Compression.inflate_if_needed(decoded_request)

      new(raw_request)
    end

    def initialize(raw_request)
      @raw_request = raw_request
    end

    def document
      @document ||= Nokogiri::XML(@raw_request)
    end

    def request_element
      @request_element ||= document.at_xpath("/samlp:AuthnRequest | /samlp:LogoutRequest", "samlp" => Namespaces::SAMLP)
    end

    # The ID of the request. It is used when responding to the request. It must be unique and only used once.
    #
    # @return [String]
    def id
      @id ||= request_element.attribute('ID').value
    end

    # The version of the request. It indicates the SAML protocol version used in the request.
    #
    # @return [String]
    def version
      @version ||= request_element.attribute('Version').value
    end

    # The IssueInstant of the request. It represents the timestamp when the request was issued.
    #
    # @return [String]
    def issue_instant
      @issue_instant ||= request_element.attribute('IssueInstant').value
    end

    # The destination of the request. It specifies the endpoint to which the request must be sent.
    # If it does not match the endpoint of the identity provider, the request must be rejected.
    #
    # @return [String, nil]
    def destination
      @destination ||= request_element.attribute('Destination')&.value
    end

    # The Consent of the request. It specifies the user's consent to the request process, if provided.
    # Possible values are:
    # - urn:oasis:names:tc:SAML:2.0:consent:unspecified
    #   * The consent of the user is not specified.
    # - urn:oasis:names:tc:SAML:2.0:consent:obtained
    #   * Specifies that user consent is acquired by the issuer of the message.
    # - urn:oasis:names:tc:SAML:2.0:consent:prior
    #   * Specifies that user consent is acquired by the issuer of the message before the action which initiated the message.
    # - urn:oasis:names:tc:SAML:2.0:consent:current-implicit
    #   * Specifies that user consent is implicitly acquired by the issuer of the message when the message was initiated.
    # - urn:oasis:names:tc:SAML:2.0:consent:current-explicit
    #   * Specifies that the user consent is explicitly acquired by the issuer of the message at the instance that the message was sent.
    # - urn:oasis:names:tc:SAML:2.0:consent:unavailable
    #   * Specifies that the issuer of the message was not able to get consent from the user.
    # - urn:oasis:names:tc:SAML:2.0:consent:inapplicable
    #   * Specifies that the issuer of the message does not need to get or report the user consent.
    #
    # @return [String, nil]
    def consent
      @consent ||= request_element.attribute('Consent')&.value
    end

    # The entity ID of the issuer. It identifies the entity that issued the SAML request.
    # This is used to determine which set of metadata to use when validating the request.
    #
    # @return [String, nil]
    def issuer_entity_id
      @issuer_entity_id ||= request_element.at_xpath('saml:Issuer')&.text
    end

    # The Signature element of the request. This element contains the XML Signature
    # associated with the request. It is used to verify the authenticity of the request.
    #
    # If the signature element is not present in the request, this will return `nil`.
    #
    # @return [Nokogiri::XML::Node, nil]
    def signature_element
      @signature_element ||= request_element.at_xpath("ds:Signature", "ds" => Namespaces::DS)
    end

    # The Extensions element of the request. This element contains optional metadata or additional elements
    # that extend the functionality of the SAML protocol.
    #
    # If the Extensions element is not present in the request, this will return `nil`.
    #
    # @return [Nokogiri::XML::Node, nil]
    def extensions_element
      @extensions_element ||= request_element.at_xpath("samlp:Extensions", "samlp" => Namespaces::SAMLP)
    end

    concerning :AuthnRequest do

      def force_authn?
        return unless request_element.name == "AuthnRequest"

        @force_authn ||= request_element.attribute("ForceAuthn")&.value == "true"
      end

      def passive?
        return unless request_element.name == "AuthnRequest"

        @passive ||= request_element.attribute("IsPassive")&.value == "true"
      end

      def protocol_binding
        return unless request_element.name == "AuthnRequest"

        @protocol_binding ||= request_element.attribute("ProtocolBinding")&.value
      end

      def assertion_consumer_service_index
        return unless request_element.name == "AuthnRequest"

        @assertion_consumer_service_index ||= request_element.attribute("AssertionConsumerServiceIndex")&.value&.to_i
      end

      def assertion_consumer_service_url
        return unless request_element.name == "AuthnRequest"

        @assertion_consumer_service_url ||= request_element.attribute("AssertionConsumerServiceURL")&.value
      end

      def attribute_consuming_service_index
        return unless request_element.name == "AuthnRequest"

        @attribute_consuming_service_index ||= request_element.attribute("AttributeConsumingServiceIndex")&.value&.to_i
      end

      def provider_name
        return unless request_element.name == "AuthnRequest"

        @provider_name ||= request_element.attribute("ProviderName")&.value
      end

      def subject_element
        return unless request_element.name == "AuthnRequest"

        @subject_element ||= request_element.at_xpath("saml:Subject", "saml" => Namespaces::SAML)
      end

      def subject
        return unless subject_element

        # TODO: Implement SubjectConfirmation and SubjectConfirmationData

        @subject ||= {
          name_id: subject_element.at_xpath("saml:NameID", "saml" => Namespaces::SAML)&.text,
          name_id_format: subject_element.at_xpath("saml:NameID", "saml" => Namespaces::SAML)&.attribute("Format")&.value,
        }
      end

      def name_id_policy_element
        return unless request_element.name == "AuthnRequest"

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
        return unless request_element.name == "AuthnRequest"

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
            .map(&:text),
          one_time_use: conditions_element.at_xpath("saml:OneTimeUse", "saml" => Namespaces::SAML).present?,
          proxy_restriction: [], # TODO: It looks like this: `<ProxyRestriction Count="2"><Audience>https://www.example.com/sp</Audience></ProxyRestriction>`
          not_before: conditions_element&.attribute("NotBefore")&.value,
          not_on_or_after: conditions_element&.attribute("NotOnOrAfter")&.value,
        }
      end

      def requested_authn_context_element
        return unless request_element.name == "AuthnRequest"

        @requested_authn_context_element ||= request_element.at_xpath("samlp:RequestedAuthnContext", "samlp" => Namespaces::SAMLP)
      end

      def requested_authn_context
        return if requested_authn_context_element.nil?

        @requested_authn_context ||= {
          class_refs: requested_authn_context_element.xpath("AuthnContextClassRef").map(&:text).presence,
          decl_refs: requested_authn_context_element.xpath("AuthnContextDeclRef").map(&:text).presence,
          comparison: requested_authn_context_element.attribute("Comparison")&.value
        }.compact
      end

      def scoping_element
        return unless request_element.name == "AuthnRequest"

        @scoping_element ||= request_element.at_xpath("samlp:Scoping", "samlp" => Namespaces::SAMLP)
      end

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
              }
            end,
            get_complete: scoping_element.at_xpath("samlp:IDPList/samlp:GetComplete", "samlp" => Namespaces::SAMLP)&.value
          }
        }
      end
    end


    module Compression
      extend self

      def inflate_if_needed(request)
        needs_inflation?(request) ? inflate(request) : request
      end

      def needs_inflation?(request)
        request.starts_with? "\x78"
      end

      def inflate(request)
        zstream = Zlib::Inflate.new
        begin
          zstream.inflate(request)
        ensure
          zstream.finish
          zstream.close
        end
      end

      def deflate(request)
        zstream = Zlib::Deflate.new(Zlib::BEST_COMPRESSION)
        begin
          zstream.deflate(request, Zlib::FINISH)
        ensure
          zstream.close
        end
      end
    end

    module Encoding
      extend self

      def decode_if_needed(request)
        needs_decoding?(request) ? decode(request) : request
      end

      def needs_decoding?(request)
        request.match?(/\A[A-Za-z0-9+\/=\n]+\z/)
      end

      def decode(request)
        Base64.decode64(request)
      end

      def encode(request)
        Base64.strict_encode64(request)
      end
    end
  end
end
