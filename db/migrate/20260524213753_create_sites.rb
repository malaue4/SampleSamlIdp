class CreateSites < ActiveRecord::Migration[8.1]
  def change
    create_table :sites do |t|
      t.string :entity_id, null: false
      t.text :signing_certificates, array: true
      t.text :encryption_certificates, array: true
      t.json :extra_settings

      t.timestamps
    end
  end
end
