# frozen_string_literal: true

module Saml
  class StatusCode
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ToXml

    RESPONDER = "urn:oasis:names:tc:SAML:2.0:status:Responder".freeze
    REQUESTER = "urn:oasis:names:tc:SAML:2.0:status:Requester".freeze
    SUCCESS = "urn:oasis:names:tc:SAML:2.0:status:Success".freeze
    PARTIAL_LOGOUT = "urn:oasis:names:tc:SAML:2.0:status:PartialLogout".freeze
    AUTHN_FAILED = "urn:oasis:names:tc:SAML:2.0:status:AuthnFailed".freeze
    NO_PASSIVE = "urn:oasis:names:tc:SAML:2.0:status:NoPassive".freeze
    PROXY_COUNT_EXCEEDED = "urn:oasis:names:tc:SAML:2.0:status:ProxyCountExceeded".freeze
    REQUEST_DENIED = "urn:oasis:names:tc:SAML:2.0:status:RequestDenied".freeze
    REQUEST_UNSUPPORTED = "urn:oasis:names:tc:SAML:2.0:status:RequestUnsupported".freeze
    REQUEST_VERSION_DEPRECATED = "urn:oasis:names:tc:SAML:2.0:status:RequestVersionDeprecated".freeze
    REQUEST_INVALID = "urn:oasis:names:tc:SAML:2.0:status:RequestInvalid".freeze
    CONDITIONAL_AUTH_REQUESTED = "urn:oasis:names:tc:SAML:2.0:status:ConditionalAuthRequested".freeze
    INVALID_NAMEID_POLICY = "urn:oasis:names:tc:SAML:2.0:status:InvalidNameIDPolicy".freeze
    INVALID_NAMEID_FORMAT = "urn:oasis:names:tc:SAML:2.0:status:InvalidNameIDFormat".freeze
    UNSUPPORTED_NAMEID_FORMAT = "urn:oasis:names:tc:SAML:2.0:status:UnsupportedNameIDFormat".freeze
    NO_SUPPORTED_NAMEID_FORMAT = "urn:oasis:names:tc:SAML:2.0:status:NoSupportedNameIDFormat".freeze
    INVALID_AC_ADDRESS = "urn:oasis:names:tc:SAML:2.0:status:InvalidAcAddress".freeze
    UNSUPPORTED_BINDING = "urn:oasis:names:tc:SAML:2.0:status:UnsupportedBinding".freeze
    UNSUPPORTED_RESPONSE_TYPE = "urn:oasis:names:tc:SAML:2.0:status:UnsupportedResponseType".freeze
    REQUEST_VERSION_TOO_HIGH = "urn:oasis:names:tc:SAML:2.0:status:RequestVersionTooHigh".freeze
    REQUEST_TOO_LONG = "urn:oasis:names:tc:SAML:2.0:status:RequestTooLong".freeze
    REQUEST_DENIED_UNKNOWN_XML_FORMAT = "urn:oasis:names:tc:SAML:2.0:status:RequestDeniedUnknownXMLFormat".freeze
    REQUEST_DENIED_UNSUPPORTED_NAMEID_FORMAT = "urn:oasis:names:tc:SAML:2.0:status:RequestDeniedUnsupportedNameIDFormat".freeze

    attribute :value, :string
    attribute :status_code

    validates :value, presence: true

    # @param [Nokogiri::XML::Node] status_code_element
    def self.parse(status_code_element)
      new(
        value: status_code_element.attribute("Value")&.value,
        status_code: status_code_element.first_element_child&.then { |child| StatusCode.parse(child) }
      )
    end


    private

    def xml_namespace
      { href: Namespaces::SAMLP, prefix: "samlp" }
    end

    def xml_attributes
      { "Value" => value }
    end

    def xml_content(builder)
      status_code&.build_xml(builder)
    end
  end
end
