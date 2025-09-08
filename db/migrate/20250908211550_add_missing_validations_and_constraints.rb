class AddMissingValidationsAndConstraints < ActiveRecord::Migration[8.0]
  def up
    # Add string length constraints for better performance and data integrity
    change_column :users, :email_address, :string, limit: 255
    change_column :users, :first_name, :string, limit: 100
    change_column :users, :last_name, :string, limit: 100
    change_column :users, :twist_username, :string, limit: 100

    change_column :subscriptions, :twist_username, :string, limit: 100
    change_column :subscriptions, :status, :string, limit: 20

    change_column :custom_projects, :project_name, :string, limit: 255
    change_column :custom_projects, :project_type, :string, limit: 50
    change_column :custom_projects, :status, :string, limit: 20

    change_column :vectors, :name, :string, limit: 255
    change_column :vectors, :category, :string, limit: 100
    change_column :vectors, :file_version, :string, limit: 50

    change_column :pichia_strains, :name, :string, limit: 255
    change_column :pichia_strains, :availability, :string, limit: 50
    change_column :pichia_strains, :viability_period, :string, limit: 100

    change_column :product_statuses, :name, :string, limit: 100
    change_column :promoters, :name, :string, limit: 100
    change_column :promoters, :full_name, :string, limit: 255
    change_column :promoters, :strength, :string, limit: 100
    change_column :selection_markers, :name, :string, limit: 100
    change_column :selection_markers, :resistance, :string, limit: 100
    change_column :selection_markers, :concentration, :string, limit: 100
    change_column :strain_types, :name, :string, limit: 100
    change_column :vector_types, :name, :string, limit: 100
    change_column :host_organisms, :common_name, :string, limit: 100
    change_column :host_organisms, :scientific_name, :string, limit: 255

    # Add NOT NULL constraints where appropriate
    change_column_null :custom_projects, :status, false
    change_column_null :vectors, :available_for_sale, false
    change_column_null :vectors, :available_for_subscription, false
    change_column_null :vectors, :has_lox_sites, false
    change_column_null :vectors, :has_files, false
    change_column_null :pichia_strains, :has_files, false
    change_column_null :promoters, :inducible, false
    change_column_null :product_statuses, :is_available, false

    # Add check constraints for enum-like columns
    add_check_constraint :custom_projects, "status IN ('pending', 'in_progress', 'completed', 'cancelled')", name: "custom_projects_status_check"
    add_check_constraint :custom_projects, "project_type IN ('strain_only', 'strain_and_testing', 'full_service', 'consultation') OR project_type IS NULL", name: "custom_projects_project_type_check"
    add_check_constraint :subscriptions, "status IN ('pending', 'active', 'expired', 'cancelled')", name: "subscriptions_status_check"
    add_check_constraint :vectors, "category IN ('Heterologous Protein Expression', 'Genome Engineering') OR category IS NULL", name: "vectors_category_check"
    add_check_constraint :promoters, "strength IN ('Weak', 'Medium', 'Strong', 'Very Strong') OR strength IS NULL", name: "promoters_strength_check"

    # Add check constraints for positive numeric values
    add_check_constraint :vectors, "sale_price > 0", name: "vectors_sale_price_positive"
    add_check_constraint :vectors, "subscription_price > 0", name: "vectors_subscription_price_positive"
    add_check_constraint :vectors, "vector_size > 0 OR vector_size IS NULL", name: "vectors_vector_size_positive"
    add_check_constraint :pichia_strains, "sale_price > 0 OR sale_price IS NULL", name: "pichia_strains_sale_price_positive"
    add_check_constraint :subscriptions, "onboarding_fee > 0", name: "subscriptions_onboarding_fee_positive"
    add_check_constraint :subscriptions, "minimum_prorated_fee > 0", name: "subscriptions_minimum_prorated_fee_positive"
    add_check_constraint :subscription_vectors, "prorated_amount >= 0 OR prorated_amount IS NULL", name: "subscription_vectors_prorated_amount_non_negative"
    add_check_constraint :custom_projects, "estimated_cost > 0 OR estimated_cost IS NULL", name: "custom_projects_estimated_cost_positive"

    # Add unique constraint for cart per user (one cart per user)
    remove_index :carts, :user_id, if_exists: true
    add_index :carts, :user_id, unique: true, if_not_exists: true
  end

  def down
    # Remove check constraints
    remove_check_constraint :custom_projects, name: "custom_projects_status_check", if_exists: true
    remove_check_constraint :custom_projects, name: "custom_projects_project_type_check", if_exists: true
    remove_check_constraint :subscriptions, name: "subscriptions_status_check", if_exists: true
    remove_check_constraint :vectors, name: "vectors_category_check", if_exists: true
    remove_check_constraint :promoters, name: "promoters_strength_check", if_exists: true
    remove_check_constraint :vectors, name: "vectors_sale_price_positive", if_exists: true
    remove_check_constraint :vectors, name: "vectors_subscription_price_positive", if_exists: true
    remove_check_constraint :vectors, name: "vectors_vector_size_positive", if_exists: true
    remove_check_constraint :pichia_strains, name: "pichia_strains_sale_price_positive", if_exists: true
    remove_check_constraint :subscriptions, name: "subscriptions_onboarding_fee_positive", if_exists: true
    remove_check_constraint :subscriptions, name: "subscriptions_minimum_prorated_fee_positive", if_exists: true
    remove_check_constraint :subscription_vectors, name: "subscription_vectors_prorated_amount_non_negative", if_exists: true
    remove_check_constraint :custom_projects, name: "custom_projects_estimated_cost_positive", if_exists: true

    # Revert string length constraints (back to no limit)
    change_column :users, :email_address, :string
    change_column :users, :first_name, :string
    change_column :users, :last_name, :string
    change_column :users, :twist_username, :string
    change_column :subscriptions, :twist_username, :string
    change_column :subscriptions, :status, :string
    change_column :custom_projects, :project_name, :string
    change_column :custom_projects, :project_type, :string
    change_column :custom_projects, :status, :string
    change_column :vectors, :name, :string
    change_column :vectors, :category, :string
    change_column :vectors, :file_version, :string
    change_column :pichia_strains, :name, :string
    change_column :pichia_strains, :availability, :string
    change_column :pichia_strains, :viability_period, :string
    change_column :product_statuses, :name, :string
    change_column :promoters, :name, :string
    change_column :promoters, :full_name, :string
    change_column :promoters, :strength, :string
    change_column :selection_markers, :name, :string
    change_column :selection_markers, :resistance, :string
    change_column :selection_markers, :concentration, :string
    change_column :strain_types, :name, :string
    change_column :vector_types, :name, :string
    change_column :host_organisms, :common_name, :string
    change_column :host_organisms, :scientific_name, :string

    # Revert NOT NULL constraints
    change_column_null :custom_projects, :status, true
    change_column_null :vectors, :available_for_sale, true
    change_column_null :vectors, :available_for_subscription, true
    change_column_null :vectors, :has_lox_sites, true
    change_column_null :vectors, :has_files, true
    change_column_null :pichia_strains, :has_files, true
    change_column_null :promoters, :inducible, true
    change_column_null :product_statuses, :is_available, true

    # Revert cart user_id index
    remove_index :carts, :user_id, if_exists: true
    add_index :carts, :user_id, if_not_exists: true
  end
end
