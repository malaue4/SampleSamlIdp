class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.belongs_to :site, null: false, foreign_key: true
      t.json :name, null: false, default: -> { "(json_object())" }
      t.json :display_name, null: false, default: -> { "(json_object())" }
      t.json :url, null: false, default: -> { "(json_object())" }

      t.timestamps
    end
  end
end
