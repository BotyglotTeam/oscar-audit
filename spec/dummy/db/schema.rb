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

ActiveRecord::Schema[8.0].define(version: 2025_12_11_234014) do
  create_table "activities_created_activities", force: :cascade do |t|
    t.string "type"
    t.string "version_record_type"
    t.integer "version_record_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["version_record_type", "version_record_id"], name: "index_activities_created_activities_on_version_record"
  end

  create_table "activities_destroyed_activities", force: :cascade do |t|
    t.string "type"
    t.string "version_record_type"
    t.integer "version_record_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["version_record_type", "version_record_id"], name: "index_activities_destroyed_activities_on_version_record"
  end

  create_table "activities_field_changes", force: :cascade do |t|
    t.string "type"
    t.string "field_name"
    t.integer "application_activity_id"
    t.boolean "previous_boolean_value"
    t.boolean "boolean_value"
    t.integer "previous_integer_value"
    t.integer "integer_value"
    t.decimal "previous_decimal_value"
    t.decimal "decimal_value"
    t.string "previous_string_value"
    t.string "string_value"
    t.text "previous_text_value"
    t.text "text_value"
    t.integer "previous_record_value_id"
    t.integer "record_value_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_activity_id"], name: "index_activities_field_changes_on_application_activity_id"
    t.index ["previous_record_value_id"], name: "index_activities_field_changes_on_previous_record_value_id"
    t.index ["record_value_id"], name: "index_activities_field_changes_on_record_value_id"
  end

  create_table "activities_updated_activities", force: :cascade do |t|
    t.string "type"
    t.string "version_record_type"
    t.integer "version_record_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["version_record_type", "version_record_id"], name: "index_activities_updated_activities_on_version_record"
  end

  create_table "oscar_activities_activities", force: :cascade do |t|
    t.string "actor_type", null: false
    t.integer "actor_id", null: false
    t.string "impersonated_by_type"
    t.integer "impersonated_by_id"
    t.string "target_type", null: false
    t.integer "target_id", null: false
    t.string "target_event", null: false
    t.string "application_activity_type", null: false
    t.integer "application_activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "idx_oaudit_acts_on_actor"
    t.index ["application_activity_type", "application_activity_id"], name: "idx_oaudit_acts_on_log"
    t.index ["created_at"], name: "idx_oscars_activities_logs_on_created_at"
    t.index ["impersonated_by_type", "impersonated_by_id"], name: "idx_oaudit_acts_on_impersonated_by"
    t.index ["target_type", "target_id"], name: "idx_oaudit_acts_on_target"
  end

  create_table "oscar_activities_actors", force: :cascade do |t|
    t.integer "type", default: 0, null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "idx_oscar_activities_actors_on_type"
  end
end
