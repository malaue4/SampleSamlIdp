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

ActiveRecord::Schema[8.1].define(version: 2026_06_13_200103) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "contact_people", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "contact_type", default: "technical", null: false
    t.string "given_name", null: false
    t.string "sur_name", null: false
    t.text "email_addresses", null: false, array: true
    t.text "telephone_numbers", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_contact_people_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.bigint "site_id", null: false
    t.json "name", default: -> { "JSON_OBJECT( RETURNING json)" }, null: false
    t.json "display_name", default: -> { "JSON_OBJECT( RETURNING json)" }, null: false
    t.json "url", default: -> { "JSON_OBJECT( RETURNING json)" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_organizations_on_site_id"
  end

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

  create_table "sites", force: :cascade do |t|
    t.string "entity_id", null: false
    t.text "signing_certificates", array: true
    t.text "encryption_certificates", array: true
    t.json "extra_settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ip_address"
    t.string "user_agent", limit: 512
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
    t.boolean "deluxe", default: false, null: false
    t.index ["name_id"], name: "index_users_on_name_id", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "contact_people", "organizations"
  add_foreign_key "organizations", "sites"
  add_foreign_key "user_sessions", "users", on_delete: :cascade
end
