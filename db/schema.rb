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

ActiveRecord::Schema[8.0].define(version: 2025_09_02_222047) do
  create_table "account_statuses", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "can_purchase", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "item_type", "item_id"], name: "index_cart_items_on_cart_id_and_item_type_and_item_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["item_type", "item_id"], name: "index_cart_items_on_item_type_and_item_id"
  end

  create_table "carts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "host_organisms", force: :cascade do |t|
    t.string "common_name", null: false
    t.string "scientific_name"
    t.text "description"
    t.text "optimal_conditions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["common_name"], name: "index_host_organisms_on_common_name"
  end

  create_table "order_statuses", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "is_complete", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organization_types", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "default_permissions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_organization_types_on_name"
  end

  create_table "pichia_strains", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "strain_type_id"
    t.text "genotype"
    t.text "phenotype"
    t.text "advantages"
    t.text "applications"
    t.decimal "sale_price", precision: 10, scale: 2
    t.string "availability"
    t.text "shipping_requirements"
    t.text "storage_conditions"
    t.string "viability_period"
    t.text "culture_media"
    t.text "growth_conditions"
    t.text "citations"
    t.boolean "has_files", default: false
    t.text "file_notes"
    t.integer "product_status_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["availability"], name: "index_pichia_strains_on_availability"
    t.index ["name"], name: "index_pichia_strains_on_name"
    t.index ["product_status_id"], name: "index_pichia_strains_on_product_status_id"
    t.index ["strain_type_id"], name: "index_pichia_strains_on_strain_type_id"
  end

  create_table "product_statuses", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "is_available", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "promoters", force: :cascade do |t|
    t.string "name", null: false
    t.string "full_name"
    t.text "description"
    t.boolean "inducible", default: false
    t.string "strength"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_promoters_on_name"
  end

  create_table "selection_markers", force: :cascade do |t|
    t.string "name", null: false
    t.string "resistance"
    t.string "concentration"
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
    t.string "name", null: false
    t.text "description"
    t.text "applications"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_strain_types_on_name"
  end

  create_table "subscription_statuses", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.boolean "admin", default: false, null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "vector_types", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "applications"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_vector_types_on_name"
  end

  create_table "vectors", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "category"
    t.boolean "available_for_sale", default: true
    t.boolean "available_for_subscription", default: true
    t.decimal "sale_price", precision: 10, scale: 2
    t.decimal "subscription_price", precision: 10, scale: 2
    t.integer "promoter_id"
    t.integer "selection_marker_id"
    t.integer "vector_type_id"
    t.boolean "has_lox_sites", default: false
    t.integer "vector_size"
    t.integer "host_organism_id"
    t.boolean "has_files", default: false
    t.string "file_version"
    t.text "features"
    t.integer "product_status_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available_for_sale"], name: "index_vectors_on_available_for_sale"
    t.index ["available_for_subscription"], name: "index_vectors_on_available_for_subscription"
    t.index ["host_organism_id"], name: "index_vectors_on_host_organism_id"
    t.index ["name"], name: "index_vectors_on_name"
    t.index ["product_status_id"], name: "index_vectors_on_product_status_id"
    t.index ["promoter_id"], name: "index_vectors_on_promoter_id"
    t.index ["selection_marker_id"], name: "index_vectors_on_selection_marker_id"
    t.index ["vector_type_id"], name: "index_vectors_on_vector_type_id"
  end

  add_foreign_key "cart_items", "carts"
  add_foreign_key "carts", "users"
  add_foreign_key "pichia_strains", "product_statuses"
  add_foreign_key "pichia_strains", "strain_types"
  add_foreign_key "sessions", "users"
  add_foreign_key "vectors", "host_organisms"
  add_foreign_key "vectors", "product_statuses"
  add_foreign_key "vectors", "promoters"
  add_foreign_key "vectors", "selection_markers"
  add_foreign_key "vectors", "vector_types"
end
