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

ActiveRecord::Schema[7.0].define(version: 2023_11_23_000009) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "full_name"
    t.string "timezone", default: "UTC"
    t.boolean "active", default: true
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "oauth_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider", null: false
    t.text "access_token_ciphertext"
    t.text "refresh_token_ciphertext"
    t.datetime "expires_at"
    t.string "scope"
    t.json "token_metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "provider"], name: "index_oauth_tokens_on_user_id_and_provider", unique: true
    t.index ["user_id"], name: "index_oauth_tokens_on_user_id"
  end

  create_table "telegram_links", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "telegram_user_id", null: false
    t.string "telegram_username"
    t.string "verification_code"
    t.boolean "verified", default: false
    t.datetime "verified_at"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["telegram_user_id"], name: "index_telegram_links_on_telegram_user_id", unique: true
    t.index ["user_id", "active"], name: "index_telegram_links_on_user_id_and_active"
    t.index ["user_id"], name: "index_telegram_links_on_user_id"
  end

  create_table "automation_settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "automation_type", null: false
    t.json "configuration"
    t.boolean "enabled", default: true
    t.integer "priority", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enabled"], name: "index_automation_settings_on_enabled"
    t.index ["user_id", "automation_type"], name: "index_automation_settings_on_user_id_and_automation_type"
    t.index ["user_id"], name: "index_automation_settings_on_user_id"
  end

  create_table "scheduler_jobs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "job_type", null: false
    t.string "schedule", null: false
    t.json "job_parameters"
    t.boolean "enabled", default: true
    t.datetime "last_run_at"
    t.datetime "next_run_at"
    t.string "last_status"
    t.text "last_error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_type"], name: "index_scheduler_jobs_on_job_type"
    t.index ["next_run_at"], name: "index_scheduler_jobs_on_next_run_at"
    t.index ["user_id", "enabled"], name: "index_scheduler_jobs_on_user_id_and_enabled"
    t.index ["user_id"], name: "index_scheduler_jobs_on_user_id"
  end

  create_table "ai_summaries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "summary_type", null: false
    t.date "summary_date"
    t.text "content"
    t.json "source_data"
    t.string "ai_model"
    t.integer "token_count"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_ai_summaries_on_status"
    t.index ["summary_type"], name: "index_ai_summaries_on_summary_type"
    t.index ["user_id", "summary_date"], name: "index_ai_summaries_on_user_id_and_summary_date"
    t.index ["user_id"], name: "index_ai_summaries_on_user_id"
  end

  create_table "crypto_data_caches", force: :cascade do |t|
    t.string "symbol", null: false
    t.decimal "price", precision: 20, scale: 8
    t.decimal "market_cap", precision: 20, scale: 2
    t.decimal "volume_24h", precision: 20, scale: 2
    t.decimal "change_24h", precision: 10, scale: 2
    t.decimal "change_7d", precision: 10, scale: 2
    t.json "additional_data"
    t.datetime "cached_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cached_at"], name: "index_crypto_data_caches_on_cached_at"
    t.index ["symbol"], name: "index_crypto_data_caches_on_symbol", unique: true
  end

  create_table "alerts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "alert_type", null: false
    t.string "title", null: false
    t.text "message"
    t.string "severity", default: "info"
    t.json "metadata"
    t.boolean "acknowledged", default: false
    t.datetime "acknowledged_at"
    t.boolean "sent", default: false
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_type"], name: "index_alerts_on_alert_type"
    t.index ["severity"], name: "index_alerts_on_severity"
    t.index ["user_id", "acknowledged"], name: "index_alerts_on_user_id_and_acknowledged"
    t.index ["user_id", "created_at"], name: "index_alerts_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_alerts_on_user_id"
  end

  create_table "n8n_webhook_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "workflow_id"
    t.string "execution_id"
    t.string "status"
    t.json "request_payload"
    t.json "response_payload"
    t.text "error_message"
    t.datetime "executed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["execution_id"], name: "index_n8n_webhook_logs_on_execution_id"
    t.index ["status"], name: "index_n8n_webhook_logs_on_status"
    t.index ["user_id"], name: "index_n8n_webhook_logs_on_user_id"
    t.index ["workflow_id"], name: "index_n8n_webhook_logs_on_workflow_id"
  end

  add_foreign_key "oauth_tokens", "users"
  add_foreign_key "telegram_links", "users"
  add_foreign_key "automation_settings", "users"
  add_foreign_key "scheduler_jobs", "users"
  add_foreign_key "ai_summaries", "users"
  add_foreign_key "alerts", "users"
  add_foreign_key "n8n_webhook_logs", "users"
end
