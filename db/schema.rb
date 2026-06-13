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

ActiveRecord::Schema[8.1].define(version: 2026_06_13_083559) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "investments", force: :cascade do |t|
    t.string "company_name", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "entry_valuation", precision: 15, scale: 2
    t.decimal "equity_percentage", precision: 8, scale: 4
    t.decimal "exit_amount", precision: 15, scale: 2
    t.date "exit_date"
    t.decimal "invested_amount", precision: 15, scale: 2, null: false
    t.date "investment_date", null: false
    t.string "sector"
    t.string "stage"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.string "vehicle", default: "direct", null: false
    t.string "website"
    t.index ["sector"], name: "index_investments_on_sector"
    t.index ["status"], name: "index_investments_on_status"
  end

  create_table "snapshots", force: :cascade do |t|
    t.decimal "arr", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.decimal "current_valuation", precision: 15, scale: 2
    t.integer "headcount"
    t.bigint "investment_id", null: false
    t.decimal "last_round_amount", precision: 15, scale: 2
    t.date "last_round_date"
    t.decimal "mrr", precision: 15, scale: 2
    t.text "notes"
    t.integer "runway_months"
    t.date "snapshot_date", null: false
    t.datetime "updated_at", null: false
    t.index ["investment_id", "snapshot_date"], name: "index_snapshots_on_investment_id_and_snapshot_date"
    t.index ["investment_id"], name: "index_snapshots_on_investment_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "share_password_digest"
    t.string "share_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["share_token"], name: "index_users_on_share_token", unique: true, where: "(share_token IS NOT NULL)"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "snapshots", "investments"
end
