json.extract! saml_metadatum, :id, :entity_id, :metadata_url, :fingerprint, :created_at, :updated_at
json.url saml_metadatum_url(saml_metadatum, format: :json)
