# frozen_string_literal: true

module Saml
  class MetadataController < ApplicationController
    def show
      organization_name = Faker::Company.name

      metadata = Metadata::EntityDescriptor.new(
        entity_id: site.entity_id,
        id: "_#{SecureRandom.uuid}",
        valid_until: 1.hour.from_now,
        cache_duration: 1.hour.iso8601,
        organization: Metadata::Organization.new(
          name: { en: organization_name },
          display_name: { en: organization_name },
          url: { en: root_url },
        ),
        contact_people: [
          Metadata::ContactPerson.new(
            contact_type: "technical",
            company: organization_name,
            given_name: name = Faker::Name.first_name,
            sur_name: lname = Faker::Name.last_name,
            email_addresses: [ Faker::Internet.email(name: "#{name} #{lname}") ],
            telephone_numbers: [ Faker::PhoneNumber.cell_phone_in_e164 ],
          ),
          Metadata::ContactPerson.new(
            contact_type: "support",
            company: organization_name,
            given_name: name = Faker::Name.first_name,
            sur_name: lname = Faker::Name.last_name,
            email_addresses: [ Faker::Internet.email(name: "#{name} #{lname}") ],
            telephone_numbers: [ Faker::PhoneNumber.cell_phone_in_e164 ],
          ),
          Metadata::ContactPerson.new(
            contact_type: "billing",
            company: organization_name,
            given_name: name = Faker::Name.first_name,
            sur_name: lname = Faker::Name.last_name,
            email_addresses: [ Faker::Internet.email(name: "#{name} #{lname}") ],
            telephone_numbers: [ Faker::PhoneNumber.cell_phone_in_e164 ],
          )
        ],
        role_descriptors: [
          Metadata::IdentityProviderSingleSignOnDescriptor.new.tap do |idp|
            idp.name_id_formats = [
              "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
            ]
            idp.key_descriptors = [
              *site.signing_certificates.map.with_index(1) do |pem_cert, i|
                Metadata::KeyDescriptor.new(
                  use: "signing",
                  key_info: Dsig::KeyInfo.new(
                    key_names: [ "signing_key#{i}" ],
                    x509_datas: [ Dsig::X509Data.new(
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
              *site.encryption_certificates.map.with_index(1) do |pem_cert, i|
                Metadata::KeyDescriptor.new(
                  use: "encryption",
                  key_info: Dsig::KeyInfo.new(
                    key_names: [ "encryption_key#{i}" ],
                    x509_datas: [ Dsig::X509Data.new(
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
              Metadata::SingleLogoutService.new(
                binding: Saml::AuthnRequest::POST_BINDING,
                location: saml_logout_url,
                response_location: saml_logout_url,
              )
            ]
            idp.single_sign_on_services = [
              Metadata::SingleSignOnService.new(
                binding: AuthnRequest::REDIRECT_BINDING,
                location: saml_auth_url,
              ),
              Metadata::SingleSignOnService.new(
                binding: Saml::AuthnRequest::POST_BINDING,
                location: saml_auth_url,
              )
            ]
            idp.saml_attributes = [
              Attribute.new(
                name: "urn:oid:0.9.2342.19200300.100.1.1",
                friendly_name: "Username",
                name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
              ),
              Attribute.new(
                name: "urn:oid:2.5.4.3",
                friendly_name: "Name",
                name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
              ),
              Attribute.new(
                name: "urn:oid:0.9.2342.19200300.100.1.3",
                friendly_name: "Email",
                name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
              ),
              Attribute.new(
                name: "urn:oid:2.5.4.20",
                friendly_name: "Phone",
                name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
              )
            ]
          end,
          Metadata::ServiceProviderSingleSignOnDescriptor.new.tap do |sp|
            sp.id = "_#{SecureRandom.uuid}"
            sp.valid_until = 1.hour.from_now
            sp.cache_duration = 1.hour
            sp.authn_requests_signed = true
            sp.want_assertions_signed = true
            sp.name_id_formats = [
              "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
            ]
            sp.single_logout_services = [
              Metadata::SingleLogoutService.new(
                binding: Saml::AuthnRequest::POST_BINDING,
                location: "saml/logout",
                response_location: "saml/logout_auth",
              )
            ]
            sp.assertion_consumer_services = [
              Metadata::AssertionConsumerService.new(
                binding: Saml::AuthnRequest::POST_BINDING,
                location: "saml/acs",
                response_location: "saml/acs_auth",
                index: 0,
                default: true
              )
            ]
            sp.attribute_consuming_services = [
              Metadata::AttributeConsumingService.new(
                service_name: { en: "Default Service Name" },
                service_description: { en: "Default Service Description" },
                requested_attributes: [
                  Metadata::RequestedAttribute.new(
                    friendly_name: "Name",
                    name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
                    name: "urn:oid:2.5.4.3",
                    required: true,
                  ),
                  Metadata::RequestedAttribute.new(
                    friendly_name: "Email",
                    name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
                    name: "urn:oid:0.9.2342.19200300.100.1.3",
                    required: false,
                  ),
                  Metadata::RequestedAttribute.new(
                    friendly_name: "Phone",
                    name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:uri",
                    name: "urn:oid:2.5.4.20",
                    required: false,
                  ),
                  Metadata::RequestedAttribute.new(
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
              Metadata::KeyDescriptor.new(
                use: "signing",
                key_info: Dsig::KeyInfo.new(
                  key_names: [ "fake_signing_key" ],
                  x509_datas: [ Dsig::X509Data.new(
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

      doc = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
        metadata.build_xml(builder)
      end.doc
      pi = Nokogiri::XML::ProcessingInstruction.new(doc, "xml-stylesheet", 'type="text/xsl" href="/saml-metadata.xsl"')
      doc.root.add_previous_sibling(pi)

      render xml: doc.to_xml
    end

    # @return [Site]
    def site
      @site ||= Site.first!
    end
  end
end
