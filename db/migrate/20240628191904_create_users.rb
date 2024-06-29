class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name_id, null: false
      t.string :name
      t.string :email
      t.string :phone

      t.timestamps
    end
    add_index :users, :name_id, unique: true
  end
end
