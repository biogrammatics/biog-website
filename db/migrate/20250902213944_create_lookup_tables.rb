class CreateLookupTables < ActiveRecord::Migration[8.0]
  def change
    create_table :promoters do |t|
      t.string :name, null: false
      t.string :full_name
      t.text :description
      t.boolean :inducible, default: false
      t.string :strength
      t.timestamps
    end

    create_table :selection_markers do |t|
      t.string :name, null: false
      t.string :resistance
      t.string :concentration
      t.text :description
      t.timestamps
    end

    create_table :vector_types do |t|
      t.string :name, null: false
      t.text :description
      t.text :applications
      t.timestamps
    end

    create_table :host_organisms do |t|
      t.string :common_name, null: false
      t.string :scientific_name
      t.text :description
      t.text :optimal_conditions
      t.timestamps
    end

    create_table :strain_types do |t|
      t.string :name, null: false
      t.text :description
      t.text :applications
      t.timestamps
    end

    create_table :organization_types do |t|
      t.string :name, null: false
      t.text :description
      t.text :default_permissions
      t.timestamps
    end

    create_table :product_statuses do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :is_available, default: true
      t.timestamps
    end

    create_table :subscription_statuses do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :is_active, default: true
      t.timestamps
    end

    create_table :order_statuses do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :is_complete, default: false
      t.timestamps
    end

    create_table :account_statuses do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :can_purchase, default: true
      t.timestamps
    end

    # Add indexes
    add_index :promoters, :name
    add_index :selection_markers, :name
    add_index :vector_types, :name
    add_index :host_organisms, :common_name
    add_index :strain_types, :name
    add_index :organization_types, :name
  end
end
