# frozen_string_literal: true

module Saml
  module Metadata
    class EncryptionMethod
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ToXml

      # @!attribute [rw] use
      #    @return [String]
      attribute :key_size, :integer
      attribute :oaep_params, :string
      attribute :algorithm, :string

      validates :algorithm, presence: true

      def self.parse(encryption_method_element)
        new(
          key_size: encryption_method_element.at_xpath("KeySize")&.text,
          oaep_params: encryption_method_element.at_xpath("OAEPParams")&.text,
          algorithm: encryption_method_element.attribute("Algorithm")&.value
        )
      end

      private

        def xml_namespace
          { href: Namespaces::MD, prefix: "md" }
        end

        def xml_attributes
          { Algorithm: algorithm }
        end

        def xml_content(builder)
          builder.KeySize(key_size) if key_size.present?
          builder.OAEPParams(oaep_params) if oaep_params.present?
      end
    end
  end
end
