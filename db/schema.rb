# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_07_01_202139) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "saml_metadata", force: :cascade do |t|
    t.string "entity_id", null: false
    t.string "metadata_url", null: false
    t.string "fingerprint"
    t.text "certificate"
    t.json "config", null: false
    t.boolean "validates_signature", default: true, null: false
    t.string "assertion_consumer_service_url"
    t.string "single_logout_service_url"
    t.text "response_hosts", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_saml_metadata_on_entity_id", unique: true
  end

  create_table "user_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name_id", null: false
    t.string "username", null: false
    t.string "password_digest", null: false
    t.string "name"
    t.string "email"
    t.string "phone"
    t.json "notes", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name_id"], name: "index_users_on_name_id", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "user_sessions", "users", on_delete: :cascade
end
