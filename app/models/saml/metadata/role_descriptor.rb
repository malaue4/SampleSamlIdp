# frozen_string_literal: true

module Saml
  module Metadata
    class RoleDescriptor
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ToXml
      include LazyAttributes

      attribute :protocol_support_enumeration, :string
      lazy_attribute(:protocol_support_enumeration) { role_descriptor_element&.attribute("protocolSupportEnumeration")&.value }
      attribute :error_url, :string
      lazy_attribute(:error_url) { role_descriptor_element&.attribute("errorURL")&.value }

      # @param [Nokogiri::XML::Node] role_descriptor_element
      def self.parse(role_descriptor_element)
        case role_descriptor_element.node_name
        when "IDPSSODescriptor" then IdentityProviderSingleSignOnDescriptor.new(role_descriptor_element:)
        when "SPSSODescriptor" then ServiceProviderSingleSignOnDescriptor.new(role_descriptor_element:)
        when "AuthnAuthorityDescriptor" then raise NotImplementedError, "AuthnAuthorityDescriptor not implemented"
        when "AttributeAuthorityDescriptor" then raise NotImplementedError, "AttributeAuthorityDescriptor not implemented"
        when "PDPDescriptor" then raise NotImplementedError, "PDPDescriptor not implemented"
        else
          new(role_descriptor_element:)
        end
      end

      # @!attribute[r] role_descriptor_element
      #   @return [Nokogiri::XML::Node] the role descriptor XML element
      attr_reader :role_descriptor_element

      # @param [Nokogiri::XML::Node] role_descriptor_element
      def initialize(role_descriptor_element: nil, **attributes)
        super(attributes)
        @role_descriptor_element = role_descriptor_element
      end

      private

        def xml_attributes
          super.merge!(
            protocolSupportEnumeration: protocol_support_enumeration,
            errorURL: error_url,
          ).compact
        end

        def xml_namespace
          { href: Namespaces::MD, prefix: "md" }
        end

        def xml_element_name
          case self
          when IdentityProviderSingleSignOnDescriptor then :IDPSSODescriptor
          when ServiceProviderSingleSignOnDescriptor then :SPSSODescriptor
          else :RoleDescriptor
          end
        end
    end
  end
end
