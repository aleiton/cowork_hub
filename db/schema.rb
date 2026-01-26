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

ActiveRecord::Schema[7.1].define(version: 2024_01_01_000006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "user_id", null: false
    t.date "date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.integer "status", default: 0, null: false
    t.jsonb "equipment_used", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_bookings_on_date"
    t.index ["equipment_used"], name: "index_bookings_on_equipment_used", using: :gin
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["user_id", "date"], name: "index_bookings_on_user_id_and_date"
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.index ["workspace_id", "date"], name: "index_bookings_on_workspace_id_and_date"
    t.index ["workspace_id"], name: "index_bookings_on_workspace_id"
  end

  create_table "cantina_subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "plan_type", default: 0, null: false
    t.integer "meals_remaining", null: false
    t.datetime "renews_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_type"], name: "index_cantina_subscriptions_on_plan_type"
    t.index ["renews_at"], name: "index_cantina_subscriptions_on_renews_at"
    t.index ["user_id", "renews_at"], name: "index_cantina_subscriptions_on_user_id_and_renews_at"
    t.index ["user_id"], name: "index_cantina_subscriptions_on_user_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "membership_type", default: 0, null: false
    t.integer "amenity_tier", default: 0, null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amenity_tier"], name: "index_memberships_on_amenity_tier"
    t.index ["ends_at"], name: "index_memberships_on_ends_at"
    t.index ["membership_type"], name: "index_memberships_on_membership_type"
    t.index ["starts_at"], name: "index_memberships_on_starts_at"
    t.index ["user_id", "ends_at"], name: "index_memberships_on_user_id_and_ends_at"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "jti", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "workshop_equipments", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "quantity_available", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_workshop_equipments_on_name"
    t.index ["workspace_id"], name: "index_workshop_equipments_on_workspace_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "workspace_type", default: 0, null: false
    t.integer "capacity", default: 1, null: false
    t.decimal "hourly_rate", precision: 10, scale: 2, null: false
    t.integer "amenity_tier", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amenity_tier"], name: "index_workspaces_on_amenity_tier"
    t.index ["workspace_type", "amenity_tier"], name: "index_workspaces_on_workspace_type_and_amenity_tier"
    t.index ["workspace_type"], name: "index_workspaces_on_workspace_type"
  end

  add_foreign_key "bookings", "users"
  add_foreign_key "bookings", "workspaces"
  add_foreign_key "cantina_subscriptions", "users"
  add_foreign_key "memberships", "users"
  add_foreign_key "workshop_equipments", "workspaces"
end
