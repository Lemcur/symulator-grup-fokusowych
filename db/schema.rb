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

ActiveRecord::Schema[8.1].define(version: 2026_06_04_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chairmen", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "focus_group_id", null: false
    t.string "llm_model", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["focus_group_id"], name: "index_chairmen_on_focus_group_id", unique: true
  end

  create_table "focus_groups", force: :cascade do |t|
    t.text "brief_summary"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "deliberation_started_at"
    t.text "error_message"
    t.jsonb "exclusion_criteria", default: []
    t.integer "generation_mode", default: 0, null: false
    t.jsonb "inclusion_criteria", default: []
    t.string "name", null: false
    t.integer "persona_generator", default: 0, null: false
    t.bigint "product_id", null: false
    t.boolean "require_persona_review", default: false, null: false
    t.integer "sample_size", null: false
    t.datetime "started_at"
    t.integer "status", default: 0, null: false
    t.datetime "synthesis_started_at"
    t.jsonb "target_demographics", default: {}, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_focus_groups_on_product_id"
    t.index ["status"], name: "index_focus_groups_on_status"
    t.index ["user_id"], name: "index_focus_groups_on_user_id"
  end

  create_table "opinions", force: :cascade do |t|
    t.text "cons"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.bigint "focus_group_id", null: false
    t.bigint "persona_id", null: false
    t.text "pros"
    t.text "quote"
    t.integer "rating"
    t.jsonb "raw_response"
    t.boolean "revised", default: false, null: false
    t.text "revision_rationale"
    t.integer "round", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["focus_group_id", "round"], name: "index_opinions_on_focus_group_id_and_round"
    t.index ["focus_group_id"], name: "index_opinions_on_focus_group_id"
    t.index ["persona_id", "round"], name: "index_opinions_on_persona_id_and_round", unique: true
    t.index ["persona_id"], name: "index_opinions_on_persona_id"
  end

  create_table "personas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "demographics"
    t.text "description"
    t.bigint "focus_group_id", null: false
    t.string "llm_model"
    t.string "llm_provider"
    t.string "name"
    t.jsonb "traits"
    t.datetime "updated_at", null: false
    t.index ["focus_group_id"], name: "index_personas_on_focus_group_id"
    t.index ["llm_model"], name: "index_personas_on_llm_model"
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "recommendations", force: :cascade do |t|
    t.jsonb "agreement_points"
    t.datetime "created_at", null: false
    t.bigint "focus_group_id", null: false
    t.datetime "generated_at"
    t.jsonb "persistent_divisions"
    t.jsonb "persuasive_arguments"
    t.jsonb "rating_distribution"
    t.jsonb "segment_insights"
    t.jsonb "strengths"
    t.text "summary"
    t.datetime "updated_at", null: false
    t.jsonb "weaknesses"
    t.index ["focus_group_id"], name: "index_recommendations_on_focus_group_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chairmen", "focus_groups"
  add_foreign_key "focus_groups", "products"
  add_foreign_key "focus_groups", "users"
  add_foreign_key "opinions", "focus_groups"
  add_foreign_key "opinions", "personas"
  add_foreign_key "personas", "focus_groups"
  add_foreign_key "products", "users"
  add_foreign_key "recommendations", "focus_groups"
end
