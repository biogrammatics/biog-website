class AddTimestampIndexesForPerformance < ActiveRecord::Migration[8.0]
  def change
    # Add indexes for created_at ordering queries found in controllers
    add_index :custom_projects, :created_at
    add_index :subscriptions, :created_at
    add_index :orders, :created_at
    add_index :addresses, :created_at

    # Add composite indexes for user-scoped timestamp ordering
    add_index :custom_projects, [ :user_id, :created_at ]
    add_index :subscriptions, [ :user_id, :created_at ]
    add_index :orders, [ :user_id, :created_at ]
    add_index :addresses, [ :user_id, :created_at ]

    # Add index for address type filtering with timestamp ordering
    add_index :addresses, [ :user_id, :address_type, :created_at ]
  end
end
