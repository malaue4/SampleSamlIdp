class SamlMetadatum < ApplicationRecord
  validates :entity_id, presence: true, uniqueness: true
  validates :metadata_url, presence: true

  before_validation do
    refresh_metadata if metadata_url.present?
  end

  private

    def refresh_metadata
      metadata = SamlIdp::IncomingMetadata.new Net::HTTP.get(URI.parse(metadata_url))

      self.validates_signature = metadata.document.signed?

      if validates_signature?
        cert = OpenSSL::X509::Certificate.new Base64.decode64 metadata.signing_certificate
        self.fingerprint = metadata.document.signed_document.fingerprint_cert cert if fingerprint.blank?
        unless metadata.document.valid_signature? fingerprint
          errors.add(:base, :invalid, message: "Metadata signature is invalid")
        end
      end
      self.config = metadata.as_json
    end
end
