class AddDeluxeToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :deluxe, :boolean, null: false, default: false
  end
end
