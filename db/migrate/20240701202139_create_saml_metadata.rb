class CreateSamlMetadata < ActiveRecord::Migration[7.2]
  def change
    create_table :saml_metadata do |t|
      t.string :entity_id, null: false
      t.json :config, null: false

      t.timestamps
    end
    add_index :saml_metadata, :entity_id, unique: true
  end
end
