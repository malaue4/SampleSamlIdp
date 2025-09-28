# frozen_string_literal: true

module Saml
  module Metadata
    class RoleDescriptor
      # @param [Nokogiri::XML::Node] role_descriptor_element
      def self.parse(role_descriptor_element)
        case role_descriptor_element.node_name
        when "IDPSSODescriptor" then IDPSSODescriptor.parse(role_descriptor_element)
        when "SPSSODescriptor" then SPSSODescriptor.parse(role_descriptor_element)
        when "AuthnAuthorityDescriptor" then raise NotImplementedError, "AuthnAuthorityDescriptor not implemented"
        when "AttributeAuthorityDescriptor" then raise NotImplementedError, "AttributeAuthorityDescriptor not implemented"
        when "PDPDescriptor" then raise NotImplementedError, "PDPDescriptor not implemented"
        else
          new(role_descriptor_element)
        end
      end

      # @!attribute[r] role_descriptor_element
      #   @return [Nokogiri::XML::Node] the role descriptor XML element
      attr_reader :role_descriptor_element

      # @param [Nokogiri::XML::Node] role_descriptor_element
      def initialize(role_descriptor_element)
        @role_descriptor_element = role_descriptor_element
      end
    end
  end
end
