# frozen_string_literal: true

SamlIdp.configure do |config|
  base = "http://sampleidp.localhost:5001"

  config.x509_certificate = <<CERT
-----BEGIN CERTIFICATE-----
MIICmDCCAgGgAwIBAgIBADANBgkqhkiG9w0BAQ0FADBpMQswCQYDVQQGEwJkazEQ
MA4GA1UECAwHWmVhbGFuZDEhMB8GA1UECgwYRG9vZmVuc2NobWlydHogRXZpbCBJ
bmMuMRYwFAYDVQQDDA1pZHAubG9jYWxob3N0MQ0wCwYDVQQHDARIZXJlMB4XDTI0
MDcwMTE3NDkzNloXDTI1MDcwMTE3NDkzNlowaTELMAkGA1UEBhMCZGsxEDAOBgNV
BAgMB1plYWxhbmQxITAfBgNVBAoMGERvb2ZlbnNjaG1pcnR6IEV2aWwgSW5jLjEW
MBQGA1UEAwwNaWRwLmxvY2FsaG9zdDENMAsGA1UEBwwESGVyZTCBnzANBgkqhkiG
9w0BAQEFAAOBjQAwgYkCgYEAwhZ6Al3sG/X4NkUm/GBhXmlF9n+pQ//plY/nfKaX
tgaqCuDgf1VbLi5BAtFdL3a/lNtJc5joRkfUqFDcCs9H3G+lk2M1tFUJ/M/pfehu
I45TyictG4IkkmzizydSfaaiE6vmGF6QIFgd4axT8sFTsCIzMmfILQiT4nv8CyJe
uZMCAwEAAaNQME4wHQYDVR0OBBYEFEZ5pN9zNjGaeqILhvd22gPrqy2tMB8GA1Ud
IwQYMBaAFEZ5pN9zNjGaeqILhvd22gPrqy2tMAwGA1UdEwQFMAMBAf8wDQYJKoZI
hvcNAQENBQADgYEAs1NmOsqgdwVu1bfkSbRpdcCcxWEsf8itA4fRdNYEn5AVm2KQ
7JOhh1F0/n/oalgeinmtMXRF1urk04J564kUBwVtZz2PZ326BXAq32knOsiUzXBd
fyrnv72X4ac+VmZqNOApjtXz3Aps1ma0t74NcQUQpM2cOTotm7t54/dHhag=
-----END CERTIFICATE-----
CERT

  # password: "curse you perry the platypus"
  config.secret_key = <<PRIVATE_KEY
-----BEGIN ENCRYPTED PRIVATE KEY-----
MIICxjBABgkqhkiG9w0BBQ0wMzAbBgkqhkiG9w0BBQwwDgQI6vkC3VAhWNgCAggA
MBQGCCqGSIb3DQMHBAj/WQPqWauSpwSCAoADIhBhKM9xHZpyR8ZWQZZOJk7HQjx/
6NV5qETOvwEljEagjg5PvTMBEq4BWowGWzEQpk8x4oMwJmeGzf1VITU4bd2cAtP6
Nri5Wj6SgyLm7eQTiThTldwF/tYcQ37CHS1rTBo96IXGVRyamdtP9t6hXQEFDmPj
P34V3OFS01O1cJur2/DHjV9g6KjQl3A/RlBoK04SinClecAxaFkbhvhg73Qvrss4
ITfrj4F/ECIBBS0mNvBkJWQQaielqHU02pG3d4eLpIs8TXBKd2/FDC26xYX3foyf
/3U0BgTHVG5IHpEvn1T8kvM7oogkeLenblCFAd6DdRXeGncQJe00CiTLlQ3RSoYF
XEXEd4FzINkwHH9lw4JAQVgSnpKppWDmxatMifTbiHhnRESP2lNOqm8RqKWBgl6i
h8lUg0q3/dIHuWZx30BWYSNWBsajz7zFJnEKW+URWNSL1EFh88wKn+LbazNDIQKo
Dt6MS4AVPzR5QTpGRxgLp9zmfjFLnGywuc+5wKFlMPqtSYCb9qQExkjb3EoqxW0x
vF55rAVS9I6Nt7WeCqflR4JPY6zIxOeGwjibP+xAH30VgZaOLXTEzBAwCM504h9W
SPmlY37fxbRcTaxJhqvwWdJvp7lUzPSKOlR0ZK63ygLToH2fcqVsw93M9JEWodLL
WuLPhHbq2xx6e412v8vsY1pGisq3Kxww3gCE2bja9eyXWef9vxjV+eZk2/g/QZY2
pnOJmUVJgKvGQscTcgAjIzwanIWO30di+9UoRJSYcyOTypz2kFIUq2m7E68kgKlu
RCKiK7RiS7Nb+NerUoYBZuZwRcoSLCG8460TViO0y/UoTbgbIXJuk/Yk
-----END ENCRYPTED PRIVATE KEY-----
PRIVATE_KEY

  csr = <<CERT
-----BEGIN CERTIFICATE REQUEST-----
MIIBqTCCARICAQAwaTELMAkGA1UEBhMCZGsxEDAOBgNVBAgMB1plYWxhbmQxITAf
BgNVBAoMGERvb2ZlbnNjaG1pcnR6IEV2aWwgSW5jLjEWMBQGA1UEAwwNaWRwLmxv
Y2FsaG9zdDENMAsGA1UEBwwESGVyZTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkC
gYEAwhZ6Al3sG/X4NkUm/GBhXmlF9n+pQ//plY/nfKaXtgaqCuDgf1VbLi5BAtFd
L3a/lNtJc5joRkfUqFDcCs9H3G+lk2M1tFUJ/M/pfehuI45TyictG4IkkmzizydS
faaiE6vmGF6QIFgd4axT8sFTsCIzMmfILQiT4nv8CyJeuZMCAwEAAaAAMA0GCSqG
SIb3DQEBDQUAA4GBALfTgRo1IBXPR7rg1QwIp3+qlnhFxxzw4+VxiUxz7q+dDR9h
OlkVrdnWsHn2e2V19v9L33YOGgZi9VRuP8VZcBz7LI8U86L3BWW7SyL0iJ9Vb9tU
npPBu85IUeXceaGgqzqeVdpsukcGwTMvRKRTP+cAsTshX07AHIddooZWjuYz
-----END CERTIFICATE REQUEST-----
CERT

  config.password = "curse you perry the platypus"
  config.algorithm = :sha256                                    # Default: sha1 only for development.
  config.organization_name = "Your Organization"
  config.organization_url = "http://example.com"
  config.base_saml_location = "#{base}/saml"
  # config.reference_id_generator                                 # Default: -> { SecureRandom.uuid }
  config.single_logout_service_post_location = "#{base}/saml/logout"
  config.single_logout_service_redirect_location = "#{base}/saml/logout"
  config.attribute_service_location = "#{base}/saml/attributes"
  config.single_service_post_location = "#{base}/saml/auth"
  config.session_expiry = 86400                                 # Default: 0 which means never
  # config.signed_message = true                                  # Default: false which means unsigned SAML Response

  # Principal (e.g. User) is passed in when you `encode_response`
  #
  # config.name_id.formats =
  #   {                         # All 2.0
  #     email_address: -> (principal) { principal.email_address },
  #     transient: -> (principal) { principal.id },
  #     persistent: -> (p) { p.id },
  #   }
  #   OR
  #
  #   {
  #     "1.1" => {
  #       email_address: -> (principal) { principal.email_address },
  #     },
  #     "2.0" => {
  #       transient: -> (principal) { principal.email_address },
  #       persistent: -> (p) { p.id },
  #     },
  #   }

  # If Principal responds to a method called `asserted_attributes`
  # the return value of that method will be used in lieu of the
  # attributes defined here in the global space. This allows for
  # per-user attribute definitions.
  #
  ## EXAMPLE **
  # class User
  #   def asserted_attributes
  #     {
  #       phone: { getter: :phone },
  #       email: {
  #         getter: :email,
  #         name_format: Saml::XML::Namespaces::Formats::NameId::EMAIL_ADDRESS,
  #         name_id_format: Saml::XML::Namespaces::Formats::NameId::EMAIL_ADDRESS
  #       }
  #     }
  #   end
  # end
  #
  # If you have a method called `asserted_attributes` in your Principal class,
  # there is no need to define it here in the config.

  # config.attributes # =>
  #   {
  #     <friendly_name> => {                                                  # required (ex "eduPersonAffiliation")
  #       "name" => <attrname>                                                # required (ex "urn:oid:1.3.6.1.4.1.5923.1.1.1.1")
  #       "name_format" => "urn:oasis:names:tc:SAML:2.0:attrname-format:uri", # not required
  #       "getter" => ->(principal) {                                         # not required
  #         principal.get_eduPersonAffiliation                                # If no "getter" defined, will try
  #       }                                                                   # `principal.eduPersonAffiliation`, or no values will
  #    }                                                                      # be output
  #
  ## EXAMPLE ##
  config.attributes = {
    Name: {
      getter: :name,
    },
    Email: {
      getter: :email,
    },
    PhoneNumber: {
      getter: :phone,
    },
  }
  ## EXAMPLE ##

  config.technical_contact.company = "Example"
  config.technical_contact.given_name = "Jonny Quest"
  config.technical_contact.sur_name = "Support"
  config.technical_contact.telephone = "55555555555"
  config.technical_contact.email_address = "example@example.com"

  service_providers = {
    "urn:example:sp" => {
      cert: OpenSSL::X509::Certificate.new(<<CERT),
-----BEGIN CERTIFICATE-----
MIIDPDCCAiQCCQDydJgOlszqbzANBgkqhkiG9w0BAQUFADBgMQswCQYDVQQGEwJV
UzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZyYW5jaXNjbzEQ
MA4GA1UEChMHSmFua3lDbzESMBAGA1UEAxMJbG9jYWxob3N0MB4XDTE0MDMxMjE5
NDYzM1oXDTI3MTExOTE5NDYzM1owYDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNh
bGlmb3JuaWExFjAUBgNVBAcTDVNhbiBGcmFuY2lzY28xEDAOBgNVBAoTB0phbmt5
Q28xEjAQBgNVBAMTCWxvY2FsaG9zdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBAMGvJpRTTasRUSPqcbqCG+ZnTAurnu0vVpIG9lzExnh11o/BGmzu7lB+
yLHcEdwrKBBmpepDBPCYxpVajvuEhZdKFx/Fdy6j5mH3rrW0Bh/zd36CoUNjbbhH
yTjeM7FN2yF3u9lcyubuvOzr3B3gX66IwJlU46+wzcQVhSOlMk2tXR+fIKQExFrO
uK9tbX3JIBUqItpI+HnAow509CnM134svw8PTFLkR6/CcMqnDfDK1m993PyoC1Y+
N4X9XkhSmEQoAlAHPI5LHrvuujM13nvtoVYvKYoj7ScgumkpWNEvX652LfXOnKYl
kB8ZybuxmFfIkzedQrbJsyOhfL03cMECAwEAATANBgkqhkiG9w0BAQUFAAOCAQEA
eHwzqwnzGEkxjzSD47imXaTqtYyETZow7XwBc0ZaFS50qRFJUgKTAmKS1xQBP/qH
pStsROT35DUxJAE6NY1Kbq3ZbCuhGoSlY0L7VzVT5tpu4EY8+Dq/u2EjRmmhoL7U
kskvIZ2n1DdERtd+YUMTeqYl9co43csZwDno/IKomeN5qaPc39IZjikJ+nUC6kPF
Keu/3j9rgHNlRtocI6S1FdtFz9OZMQlpr0JbUt2T3xS/YoQJn6coDmJL5GTiiKM6
cOe+Ur1VwzS1JEDbSS2TWWhzq8ojLdrotYLGd9JOsoQhElmz+tMfCFQUFLExinPA
yy7YHlSiVX13QH2XTu/iQQ==
-----END CERTIFICATE-----
CERT
      metadata_url: "http://localhost:7070/metadata",

      # We now validate AssertionConsumerServiceURL will match the MetadataURL set above.
      # *If* it's not going to match your Metadata URL's Host, then set this so we can validate the host using this list
      response_hosts: ["localhost"]
    },
  }

  # `identifier` is the entity_id or issuer of the Service Provider,
  # settings is an IncomingMetadata object which has a to_h method that needs to be persisted
  config.service_provider.metadata_persister = ->(identifier, settings) {
    metadatum = SamlMetadatum.find_by!(entity_id: identifier)
    metadatum.metadata_url ||= "settings.metadata_url"
    metadatum.config ||= settings.to_h || {}
    # metadatum.save!
  }

  # `identifier` is the entity_id or issuer of the Service Provider,
  # `service_provider` is a ServiceProvider object. Based on the `identifier` or the
  # `service_provider` you should return the settings.to_h from above
  config.service_provider.persisted_metadata_getter = ->(identifier, service_provider){
    data = SamlMetadatum.find_by!(entity_id: identifier)
    data.parsed_metadata
  }

  # Find ServiceProvider metadata_url and fingerprint based on our settings
  config.service_provider.finder = ->(issuer_or_entity_id) do
    service_providers[issuer_or_entity_id]
  end
end
