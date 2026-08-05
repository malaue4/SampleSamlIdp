class CreateContactPeople < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_people do |t|
      t.belongs_to :organization, null: false, foreign_key: true
      t.string :contact_type, null: false, default: "technical"
      t.string :given_name, null: false
      t.string :sur_name, null: false
      t.text :email_addresses, null: false, array: true
      t.text :telephone_numbers, null: false, array: true

      t.timestamps
    end
  end
end
