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

ActiveRecord::Schema[8.0].define(version: 2025_09_08_212207) do
  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "item_type", "item_id"], name: "index_cart_items_on_cart_id_and_item_type_and_item_id", unique: true
    t.index ["item_type", "item_id"], name: "index_cart_items_on_item_type_and_item_id"
  end

  create_table "carts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id", unique: true
  end

  create_table "custom_projects", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "project_name", limit: 255
    t.string "project_type", limit: 50
    t.text "description"
    t.boolean "strain_generation", default: false
    t.boolean "expression_testing", default: false
    t.string "status", limit: 20, null: false
    t.text "notes"
    t.decimal "estimated_cost", precision: 10, scale: 2
    t.date "estimated_completion_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_type"], name: "index_custom_projects_on_project_type"
    t.index ["status"], name: "index_custom_projects_on_status"
    t.index ["user_id"], name: "index_custom_projects_on_user_id"
    t.check_constraint "estimated_cost > 0 OR estimated_cost IS NULL", name: "custom_projects_estimated_cost_positive"
    t.check_constraint "project_type IN ('strain_only', 'strain_and_testing', 'full_service', 'consultation') OR project_type IS NULL", name: "custom_projects_project_type_check"
    t.check_constraint "status IN ('pending', 'in_progress', 'completed', 'cancelled')", name: "custom_projects_status_check"
  end

  create_table "host_organisms", force: :cascade do |t|
    t.string "common_name", limit: 100
    t.string "scientific_name", limit: 255
    t.text "description"
    t.text "optimal_conditions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["common_name"], name: "index_host_organisms_on_common_name"
  end

  create_table "pichia_strains", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.integer "strain_type_id"
    t.text "genotype"
    t.text "phenotype"
    t.text "advantages"
    t.text "applications"
    t.decimal "sale_price", precision: 10, scale: 2
    t.string "availability", limit: 50
    t.text "shipping_requirements"
    t.text "storage_conditions"
    t.string "viability_period", limit: 100
    t.text "culture_media"
    t.text "growth_conditions"
    t.text "citations"
    t.boolean "has_files", default: false, null: false
    t.text "file_notes"
    t.integer "product_status_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["availability"], name: "index_pichia_strains_on_availability"
    t.index ["name"], name: "index_pichia_strains_on_name"
    t.index ["product_status_id"], name: "index_pichia_strains_on_product_status_id"
    t.index ["strain_type_id"], name: "index_pichia_strains_on_strain_type_id"
    t.check_constraint "sale_price > 0 OR sale_price IS NULL", name: "pichia_strains_sale_price_positive"
  end

  create_table "product_statuses", force: :cascade do |t|
    t.string "name", limit: 100
    t.text "description"
    t.boolean "is_available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "promoters", force: :cascade do |t|
    t.string "name", limit: 100
    t.string "full_name", limit: 255
    t.text "description"
    t.boolean "inducible", default: false, null: false
    t.string "strength", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_promoters_on_name"
    t.check_constraint "strength IN ('Weak', 'Medium', 'Strong', 'Very Strong') OR strength IS NULL", name: "promoters_strength_check"
  end

  create_table "selection_markers", force: :cascade do |t|
    t.string "name", limit: 100
    t.string "resistance", limit: 100
    t.string "concentration", limit: 100
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_selection_markers_on_name"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "strain_types", force: :cascade do |t|
    t.string "name", limit: 100
    t.text "description"
    t.text "applications"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_strain_types_on_name"
  end

  create_table "subscription_vectors", force: :cascade do |t|
    t.integer "subscription_id", null: false
    t.integer "vector_id", null: false
    t.datetime "added_at", null: false
    t.decimal "prorated_amount", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["added_at"], name: "index_subscription_vectors_on_added_at"
    t.index ["subscription_id", "vector_id"], name: "index_subscription_vectors_on_subscription_id_and_vector_id", unique: true
    t.index ["subscription_id"], name: "index_subscription_vectors_on_subscription_id"
    t.index ["vector_id"], name: "index_subscription_vectors_on_vector_id"
    t.check_constraint "prorated_amount >= 0 OR prorated_amount IS NULL", name: "subscription_vectors_prorated_amount_non_negative"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "twist_username", limit: 100
    t.decimal "onboarding_fee", precision: 8, scale: 2, default: "300.0"
    t.string "status", limit: 20
    t.datetime "started_at"
    t.date "renewal_date"
    t.decimal "minimum_prorated_fee", precision: 8, scale: 2, default: "50.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["user_id", "status"], name: "index_subscriptions_on_user_id_and_status", where: "status = 'active'"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
    t.check_constraint "minimum_prorated_fee > 0", name: "subscriptions_minimum_prorated_fee_positive"
    t.check_constraint "onboarding_fee > 0", name: "subscriptions_onboarding_fee_positive"
    t.check_constraint "status IN ('pending', 'active', 'expired', 'cancelled')", name: "subscriptions_status_check"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", limit: 255
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", limit: 100
    t.string "last_name", limit: 100
    t.boolean "admin", default: false, null: false
    t.string "twist_username", limit: 100
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "vector_types", force: :cascade do |t|
    t.string "name", limit: 100
    t.text "description"
    t.text "applications"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_vector_types_on_name"
  end

  create_table "vectors", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.string "category", limit: 100
    t.boolean "available_for_sale", default: true, null: false
    t.boolean "available_for_subscription", default: true, null: false
    t.decimal "sale_price", precision: 10, scale: 2
    t.decimal "subscription_price", precision: 10, scale: 2
    t.integer "promoter_id"
    t.integer "selection_marker_id"
    t.integer "vector_type_id"
    t.boolean "has_lox_sites", default: false, null: false
    t.integer "vector_size"
    t.integer "host_organism_id"
    t.boolean "has_files", default: false, null: false
    t.string "file_version", limit: 50
    t.text "features"
    t.integer "product_status_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available_for_sale"], name: "index_vectors_on_available_for_sale"
    t.index ["available_for_subscription"], name: "index_vectors_on_available_for_subscription"
    t.index ["category", "product_status_id"], name: "index_vectors_on_category_and_product_status_id"
    t.index ["category"], name: "index_vectors_on_category"
    t.index ["host_organism_id"], name: "index_vectors_on_host_organism_id"
    t.index ["name"], name: "index_vectors_on_name"
    t.index ["product_status_id"], name: "index_vectors_on_product_status_id"
    t.index ["promoter_id"], name: "index_vectors_on_promoter_id"
    t.index ["selection_marker_id"], name: "index_vectors_on_selection_marker_id"
    t.index ["vector_type_id"], name: "index_vectors_on_vector_type_id"
    t.check_constraint "category IN ('Heterologous Protein Expression', 'Genome Engineering') OR category IS NULL", name: "vectors_category_check"
    t.check_constraint "sale_price > 0", name: "vectors_sale_price_positive"
    t.check_constraint "subscription_price > 0", name: "vectors_subscription_price_positive"
    t.check_constraint "vector_size > 0 OR vector_size IS NULL", name: "vectors_vector_size_positive"
  end

  add_foreign_key "cart_items", "carts"
  add_foreign_key "carts", "users"
  add_foreign_key "custom_projects", "users"
  add_foreign_key "pichia_strains", "product_statuses"
  add_foreign_key "pichia_strains", "strain_types"
  add_foreign_key "sessions", "users"
  add_foreign_key "subscription_vectors", "subscriptions"
  add_foreign_key "subscription_vectors", "vectors"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "vectors", "host_organisms"
  add_foreign_key "vectors", "product_statuses"
  add_foreign_key "vectors", "promoters"
  add_foreign_key "vectors", "selection_markers"
  add_foreign_key "vectors", "vector_types"
end
