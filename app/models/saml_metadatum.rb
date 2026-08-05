class SamlMetadatum < ApplicationRecord
  validates :entity_id, presence: true, uniqueness: true
  # validates :metadata_url, presence: true

  before_validation do
    refresh_metadata if metadata_url.present? && metadata_url_changed?
  end

  # @return [Saml::Metadata::EntityDescriptor]
  def parsed_metadata
    @parsed_metadata ||= Saml::Metadata::EntityDescriptor.parse(config["raw"])
  end

  def raw_xml
    @raw_xml ||= config&.fetch("raw", "")
  end

  def raw_xml=(xml)
    self.config ||= {}
    config["raw"] = xml
  end

  private

    def refresh_metadata
      uri = begin
        URI.parse(metadata_url)
      rescue URI::InvalidURIError
        errors.add(:base, :invalid, message: "Metadata URL is invalid")
        return
            end

      # Validate that the url is http or https
      unless uri.scheme == "http" || uri.scheme == "https"
        errors.add(:base, :invalid, message: "Metadata URL must use http or https scheme")
        return
      end

      response = begin
        Net::HTTP.get(uri)
      rescue StandardError => e # TODO: be more specific
        errors.add(:base, :invalid, message: "Metadata URL is invalid: #{e.message}")
        return
      end

      metadata = Saml::Metadata::EntityDescriptor.parse(response)

      self.validates_signature = validates_signature? && metadata.signed?

      if validates_signature?
        cert = OpenSSL::X509::Certificate.new Base64.decode64 metadata.signing_certificate
        signed_document = Xmldsig::SignedDocument.new(metadata.document)

        self.fingerprint = metadata.document.signed_document.fingerprint_cert cert if fingerprint.blank?
        unless metadata.document.valid_signature? fingerprint
          errors.add(:base, :invalid, message: "Metadata signature is invalid")
        end
      end
      self.config = metadata.as_json
    end
end
