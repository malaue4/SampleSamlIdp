# frozen_string_literal: true

module Saml
  module Metadata
    class SingleSignOnDescriptor < RoleDescriptor

      # @!attribute [rw] name_id_formats
      #   @return [Array<String>] list of supported NameID formats
      attribute :name_id_formats
      lazy_attribute(:name_id_formats) do
        role_descriptor_element&.xpath("md:NameIDFormat", "md" => Namespaces::MD)&.map(&:text) || []
      end

      attr_accessor :artifact_resolution_services, :single_logout_services, :manage_name_id_services

      def artifact_resolution_services
        @artifact_resolution_services ||= role_descriptor_element
          &.xpath("md:ArtifactResolutionService", "md" => Namespaces::MD)
          &.map do |service|
          ArtifactResolutionService.parse(service)
        end || []
      end

      def single_logout_services
        @single_logout_services ||= role_descriptor_element
          &.xpath("md:SingleLogoutService", "md" => Namespaces::MD)
          &.map do |service|
          SingleLogoutService.parse(service)
        end || []
      end

      def manage_name_id_services
        @manage_name_id_services ||= role_descriptor_element
          &.xpath("md:ManageNameIDService", "md" => Namespaces::MD)
          &.map do |service|
          ManageNameIdService.parse(service)
        end || []
      end

      private

        def xml_content(builder)
          super
          artifact_resolution_services&.each { |s| s.build_xml(builder) }
          single_logout_services&.each { |s| s.build_xml(builder) }
          manage_name_id_services&.each { |s| s.build_xml(builder) }
          name_id_formats&.each do |format|
            builder[:md].NameIDFormat format
          end
        end
    end
  end
end
