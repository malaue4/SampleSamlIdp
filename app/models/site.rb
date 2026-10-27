class Site < ApplicationRecord
  store_accessor(:extra_settings, :organization_name, :organization_display_name, :organization_url)

  normalizes :signing_certificates, :encryption_certificates, with: proc { |certs|
    Array(certs).filter_map do |cert|
      cert.to_s.strip.presence
    end
  }


  validate do
    signing_certificates.each do |it|
      OpenSSL::X509::Certificate.load(it)
    rescue StandardError => e
      errors.add(:signing_certificates, :invalid, message: e.message)
    end
    encryption_certificates.each do |it|
      OpenSSL::X509::Certificate.load(it)
    rescue StandardError => e
      errors.add(:encryption_certificates, :invalid, message: e.message)
    end
  end

  def generate_metadata
    metadata = Saml::Metadata::EntityDescriptor.new(
      entity_id: entity_id,
      id: "_#{SecureRandom.uuid}",
      valid_until: 1.hour.from_now,
      cache_duration: 1.hour.iso8601,
      organization: Saml::Metadata::Organization.new(
        name: { en: organization_name },
        display_name: { en: organization_display_name },
        url: { en: organization_url },
        ),
      contact_people: [
        Saml::Metadata::ContactPerson.new(
          contact_type: "technical",
          company: organization_name,
          given_name: name = Faker::Name.first_name,
          sur_name: lname = Faker::Name.last_name,
          email_addresses: [ Faker::Internet.email(name: "#{name} #{lname}") ],
          telephone_numbers: [ Faker::PhoneNumber.cell_phone_in_e164 ],
          ),
        Saml::Metadata::ContactPerson.new(
          contact_type: "support",
          company: organization_name,
          given_name: name = Faker::Name.first_name,
          sur_name: lname = Faker::Name.last_name,
          email_addresses: [ Faker::Internet.email(name: "#{name} #{lname}") ],
          telephone_numbers: [ Faker::PhoneNumber.cell_phone_in_e164 ],
          ),
        Saml::Metadata::ContactPerson.new(
          contact_type: "billing",
          company: organization_name,
          given_name: name = Faker::Name.first_name,
          sur_name: lname = Faker::Name.last_name,
          email_addresses: [ Faker::Internet.email(name: "#{name} #{lname}") ],
          telephone_numbers: [ Faker::PhoneNumber.cell_phone_in_e164 ],
          )
      ],
      role_descriptors: [
        Saml::Metadata::IdentityProviderSingleSignOnDescriptor.new.tap do |idp|
          idp.name_id_formats = [
            "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
          ]
          idp.key_descriptors = [
            *signing_certificates.map.with_index(1) do |pem_cert, i|
              Saml::Metadata::KeyDescriptor.new(
                use: "signing",
                key_info: Saml::Dsig::KeyInfo.new(
                  key_names: [ "signing_key#{i}" ],
                  x509_datas: [ Saml::Dsig::X509Data.new(
                    elements:
                      [
                        {
                          type: :x509_certificate,
                          value: pem_cert.gsub(/(-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----|\r?\n)/, "")
                        }
                      ],
                    )
                  ]
                )
              )
            end,
            *encryption_certificates.map.with_index(1) do |pem_cert, i|
              Saml::Metadata::KeyDescriptor.new(
                use: "encryption",
                key_info: Saml::Dsig::KeyInfo.new(
                  key_names: [ "encryption_key#{i}" ],
                  x509_datas: [ Saml::Dsig::X509Data.new(
                    elements:
                      [
                        {
                          type: :x509_certificate,
                          value: pem_cert.gsub(/(-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----|\r?\n)/, "")
                        }
                      ],
                    )
                  ]
                )
              )
            end
          ]
          idp.want_authn_requests_signed = true
          idp.single_logout_services = [
            Saml::Metadata::SingleLogoutService.new(
              binding: Saml::AuthnRequest::POST_BINDING,
              location: Rails.application.routes.url_helpers.saml_logout_url(host: "localhost"),
              response_location: Rails.application.routes.url_helpers.saml_logout_url(host: "localhost"),
              )
          ]
          idp.single_sign_on_services = [
            Saml::Metadata::SingleSignOnService.new(
              binding: Saml::AuthnRequest::REDIRECT_BINDING,
              location: Rails.application.routes.url_helpers.saml_auth_url(host: "localhost"),
              ),
            Saml::Metadata::SingleSignOnService.new(
              binding: Saml::AuthnRequest::POST_BINDING,
              location: Rails.application.routes.url_helpers.saml_auth_url(host: "localhost"),
              )
          ]
          idp.saml_attributes = [
            Saml::Attribute.new(
              name: "urn:oid:0.9.2342.19200300.100.1.1",
              friendly_name: "Username",
              name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
            ),
            Saml::Attribute.new(
              name: "urn:oid:2.5.4.3",
              friendly_name: "Name",
              name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
            ),
            Saml::Attribute.new(
              name: "urn:oid:0.9.2342.19200300.100.1.3",
              friendly_name: "Email",
              name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
            ),
            Saml::Attribute.new(
              name: "urn:oid:2.5.4.20",
              friendly_name: "Phone",
              name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
            )
          ]
        end,
        Saml::Metadata::ServiceProviderSingleSignOnDescriptor.new.tap do |sp|
          sp.id = "_#{SecureRandom.uuid}"
          sp.valid_until = 1.hour.from_now
          sp.cache_duration = 1.hour
          sp.authn_requests_signed = true
          sp.want_assertions_signed = true
          sp.name_id_formats = [
            "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
          ]
          sp.single_logout_services = [
            Saml::Metadata::SingleLogoutService.new(
              binding: Saml::AuthnRequest::POST_BINDING,
              location: "saml/logout",
              response_location: "saml/logout_auth",
              )
          ]
          sp.assertion_consumer_services = [
            Saml::Metadata::AssertionConsumerService.new(
              binding: Saml::AuthnRequest::POST_BINDING,
              location: "saml/acs",
              response_location: "saml/acs_auth",
              index: 0,
              default: true
            )
          ]
          sp.attribute_consuming_services = [
            Saml::Metadata::AttributeConsumingService.new(
              service_name: { en: "Default Service Name" },
              service_description: { en: "Default Service Description" },
              requested_attributes: [
                Saml::Metadata::RequestedAttribute.new(
                  friendly_name: "Name",
                  name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
                  name: "urn:oid:2.5.4.3",
                  required: true,
                  ),
                Saml::Metadata::RequestedAttribute.new(
                  friendly_name: "Email",
                  name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
                  name: "urn:oid:0.9.2342.19200300.100.1.3",
                  required: false,
                  ),
                Saml::Metadata::RequestedAttribute.new(
                  friendly_name: "Phone",
                  name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
                  name: "urn:oid:2.5.4.20",
                  required: false,
                  ),
                Saml::Metadata::RequestedAttribute.new(
                  friendly_name: "Preferred Language",
                  name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
                  name: "urn:oid:2.16.840.1.113730.3.1.39",
                  required: false,
                  )
              ],
              index: 0,
              default: true,
              )
          ]
          sp.key_descriptors = [
            Saml::Metadata::KeyDescriptor.new(
              use: "signing",
              key_info: Saml::Dsig::KeyInfo.new(
                key_names: [ "fake_signing_key" ],
                x509_datas: [ Saml::Dsig::X509Data.new(
                  elements: [
                    {
                      type: :x509_certificate,
                      value: "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA..."
                    }
                  ]
                ) ],
                )
            )
          ]
        end
      ]
    )
  end
end
