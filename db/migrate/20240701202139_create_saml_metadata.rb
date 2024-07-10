class CreateSamlMetadata < ActiveRecord::Migration[7.2]
  def change
    create_table :saml_metadata do |t|
      t.string :entity_id, null: false
      t.string :metadata_url, null: false
      t.string :fingerprint
      t.text :certificate
      t.json :config, null: false
      t.boolean :validates_signature, default: true, null: false
      t.string :assertion_consumer_service_url
      t.string :single_logout_service_url
      t.text :response_hosts, array: true, default: []

      t.timestamps
    end
    add_index :saml_metadata, :entity_id, unique: true
  end
end
