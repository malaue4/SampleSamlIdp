class CreateUserSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :user_sessions do |t|
      t.belongs_to :user, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :expires_at, null: false

      t.timestamps
    end
  end
end
