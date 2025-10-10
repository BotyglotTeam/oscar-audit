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

ActiveRecord::Schema[8.0].define(version: 2025_10_10_164759) do
  create_table "oscar_activities_activities", force: :cascade do |t|
    t.integer "activity_definition_id", null: false
    t.string "actor_type", null: false
    t.integer "actor_id", null: false
    t.string "impersonated_by_type"
    t.integer "impersonated_by_id"
    t.string "target_type", null: false
    t.integer "target_id", null: false
    t.string "log_type"
    t.integer "log_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_definition_id"], name: "idx_oa_acts_on_definition_id"
    t.index ["actor_type", "actor_id"], name: "idx_oa_acts_on_actor"
    t.index ["created_at"], name: "idx_oa_acts_on_created_at"
    t.index ["impersonated_by_type", "impersonated_by_id"], name: "idx_oa_acts_on_impersonated_by"
    t.index ["log_type", "log_id"], name: "idx_oa_acts_on_log"
    t.index ["target_type", "target_id"], name: "idx_oa_acts_on_target"
  end

  create_table "oscar_activities_activity_definitions", force: :cascade do |t|
    t.string "model_type", null: false
    t.string "model_event_name", null: false
    t.string "log_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["model_type", "model_event_name"], name: "idx_oa_acts_def_on_model_event", unique: true
  end

  add_foreign_key "oscar_activities_activities", "oscar_activities_definitions", column: "activity_definition_id"
end
