class SamlMetadatum < ApplicationRecord
  validates :entity_id, presence: true, uniqueness: true
  validates :metadata_url, presence: true

  before_validation do
    refresh_metadata if metadata_url.present? && metadata_url_changed?
  end

  def parsed_metadata
    @parsed_metadata ||= begin
      im = SamlIdp::IncomingMetadata.new config["raw"]
      im.define_singleton_method(:role_descriptor_document) { im.service_provider_descriptor_document }
      im.define_singleton_method(:display_name) do
        xpath("//md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName",
              md: Saml::XML::Namespaces::METADATA,
              mdui: "urn:oasis:names:tc:SAML:metadata:ui"
        ).first&.content || ""
      end
      im.define_singleton_method(:logo) do
        xpath("//md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Logo",
              md: Saml::XML::Namespaces::METADATA,
              mdui: "urn:oasis:names:tc:SAML:metadata:ui"
        ).first&.content || ""
      end
      {
        entity_id: im.entity_id,
        display_name: im.display_name,
        assertion_consumer_services: im.assertion_consumer_services,
        single_logout_services: im.single_logout_services,
        name_id_formats: im.name_id_formats,
        signing_certificate: im.signing_certificate,
        cert: im.signing_certificate,
        encryption_certificate: im.encryption_certificate,
        contact_person: im.contact_person,
        sign_assertions: im.sign_assertions,
        sign_authn_request: im.sign_authn_request,
        logo: im.logo.squish,
        fingerprint: SamlIdp::Fingerprint.certificate_digest("-----BEGIN CERTIFICATE-----\n#{im.signing_certificate}\n-----END CERTIFICATE-----\n"),
      }
    end
  end

  private

    def refresh_metadata
      metadata = SamlIdp::IncomingMetadata.new Net::HTTP.get(URI.parse(metadata_url))

      self.validates_signature = validates_signature? && metadata.document.signed?

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
