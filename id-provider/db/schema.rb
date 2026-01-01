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

ActiveRecord::Schema[7.1].define(version: 2026_01_01_121831) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "client_id", null: false
    t.bigint "authorization_code_id"
    t.string "token", null: false
    t.text "scopes", default: [], array: true
    t.string "token_type", default: "Bearer"
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorization_code_id"], name: "index_access_tokens_on_authorization_code_id"
    t.index ["client_id"], name: "index_access_tokens_on_client_id"
    t.index ["token"], name: "index_access_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_access_tokens_on_user_id"
  end

  create_table "authorization_codes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "client_id", null: false
    t.string "code", null: false
    t.text "redirect_uri", null: false
    t.text "scopes", default: [], array: true
    t.string "nonce"
    t.string "code_challenge"
    t.string "code_challenge_method"
    t.datetime "expires_at", null: false
    t.boolean "used", default: false
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_authorization_codes_on_client_id"
    t.index ["code", "used"], name: "index_authorization_codes_on_code_and_used"
    t.index ["code"], name: "index_authorization_codes_on_code", unique: true
    t.index ["user_id"], name: "index_authorization_codes_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "client_id", null: false
    t.string "client_secret", null: false
    t.string "name"
    t.text "redirect_uris", default: [], array: true
    t.text "grant_types", default: [], array: true
    t.text "response_types", default: [], array: true
    t.text "scopes", default: [], array: true
    t.string "client_uri"
    t.string "logo_uri"
    t.string "policy_uri"
    t.string "tos_uri"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_clients_on_client_id", unique: true
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "client_id", null: false
    t.bigint "access_token_id"
    t.string "token", null: false
    t.text "scopes", default: [], array: true
    t.datetime "expires_at", null: false
    t.boolean "revoked", default: false
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token_id"], name: "index_refresh_tokens_on_access_token_id"
    t.index ["client_id"], name: "index_refresh_tokens_on_client_id"
    t.index ["token"], name: "index_refresh_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "user_consents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "client_id", null: false
    t.text "scopes"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_user_consents_on_client_id"
    t.index ["user_id", "client_id"], name: "index_user_consents_on_user_id_and_client_id", unique: true
    t.index ["user_id"], name: "index_user_consents_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "sub", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name"
    t.string "given_name"
    t.string "family_name"
    t.string "picture"
    t.boolean "email_verified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["sub"], name: "index_users_on_sub", unique: true
  end

  add_foreign_key "access_tokens", "authorization_codes"
  add_foreign_key "access_tokens", "clients"
  add_foreign_key "access_tokens", "users"
  add_foreign_key "authorization_codes", "clients"
  add_foreign_key "authorization_codes", "users"
  add_foreign_key "refresh_tokens", "access_tokens"
  add_foreign_key "refresh_tokens", "clients"
  add_foreign_key "refresh_tokens", "users"
  add_foreign_key "user_consents", "clients"
  add_foreign_key "user_consents", "users"
end
