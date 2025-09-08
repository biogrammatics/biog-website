class RemoveUnusedTables < ActiveRecord::Migration[8.0]
  def up
    # Remove tables that don't have corresponding models and aren't being used
    drop_table :account_statuses, if_exists: true
    drop_table :organization_types, if_exists: true
    drop_table :order_statuses, if_exists: true
    drop_table :subscription_statuses, if_exists: true
  end

  def down
    # Recreate tables in case rollback is needed (based on current schema)
    create_table :account_statuses do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :can_purchase, default: true
      t.timestamps
    end

    create_table :organization_types do |t|
      t.string :name, null: false
      t.text :description
      t.text :default_permissions
      t.timestamps
      t.index :name
    end

    create_table :order_statuses do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :is_complete, default: false
      t.timestamps
    end

    create_table :subscription_statuses do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :is_active, default: true
      t.timestamps
    end
  end
end
