# frozen_string_literal: true

module Saml
  module Metadata
    class SingleSignOnDescriptor < RoleDescriptor


      def artifact_resolution_services
        @artifact_resolution_services ||= role_descriptor_element
          .xpath("md:ArtifactResolutionService", "md" => Namespaces::MD)
          .map do |service|
          ArtifactResolutionService.parse(service)
        end
      end

      def single_logout_services
        @single_logout_services ||= role_descriptor_element
          .xpath("md:SingleLogoutService", "md" => Namespaces::MD)
          .map do |service|
          SingleLogoutService.parse(service)
        end
      end

      def manage_name_id_services
        @manage_name_id_services ||= role_descriptor_element
          .xpath("md:ManageNameIDService", "md" => Namespaces::MD)
          .map do |service|
          ManageNameIdService.parse(service)
        end
      end

      def name_id_formats
        @name_id_formats ||= role_descriptor_element
          .xpath("md:NameIDFormat", "md" => Namespaces::MD)
          .map do |service|
          service.text
        end
      end

      def as_json
        super.merge!(
          artifact_resolution_services:,
          single_logout_services:,
          manage_name_id_services:,
          name_id_formats:,
        )
      end
    end
  end
end
