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

ActiveRecord::Schema[7.1].define(version: 2025_12_01_162852) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "health_insurances", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "insurance_coverages", force: :cascade do |t|
    t.bigint "health_insurance_id", null: false
    t.bigint "service_id", null: false
    t.boolean "covered"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["health_insurance_id"], name: "index_insurance_coverages_on_health_insurance_id"
    t.index ["service_id"], name: "index_insurance_coverages_on_service_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "enabled"
    t.boolean "sms"
    t.boolean "push"
    t.boolean "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "gender"
    t.date "birthday"
    t.string "phone_number"
    t.string "user_name"
    t.string "field_of_work"
    t.string "zip_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.text "description"
    t.integer "recommended_start_age"
    t.integer "recommended_end_age"
    t.string "gender_restriction"
    t.integer "frequency_months"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_insurances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "health_insurance_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["health_insurance_id"], name: "index_user_insurances_on_health_insurance_id"
    t.index ["user_id"], name: "index_user_insurances_on_user_id"
  end

  create_table "user_services", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "service_id", null: false
    t.date "due_date"
    t.string "status"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_user_services_on_service_id"
    t.index ["user_id"], name: "index_user_services_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "insurance_coverages", "health_insurances"
  add_foreign_key "insurance_coverages", "services"
  add_foreign_key "notifications", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "user_insurances", "health_insurances"
  add_foreign_key "user_insurances", "users"
  add_foreign_key "user_services", "services"
  add_foreign_key "user_services", "users"
end
