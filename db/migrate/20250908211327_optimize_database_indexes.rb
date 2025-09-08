class OptimizeDatabaseIndexes < ActiveRecord::Migration[8.0]
  def up
    # Add missing indexes that would improve performance

    # Add index on vectors.category since we're now grouping by this
    add_index :vectors, :category, if_not_exists: true

    # Add composite index for common vector queries (category + status)
    add_index :vectors, [ :category, :product_status_id ], if_not_exists: true

    # Add index for email lookup (should be unique anyway)
    remove_index :users, :email_address, if_exists: true
    add_index :users, :email_address, unique: true

    # Add index for cart lookups by user
    add_index :carts, :user_id, unique: true, if_not_exists: true

    # Remove redundant indexes that are covered by compound indexes
    # The compound index on cart_items already covers cart_id, so single index is redundant
    remove_index :cart_items, :cart_id, if_exists: true

    # Add partial index for active subscriptions only (more efficient)
    add_index :subscriptions, [ :user_id, :status ], where: "status = 'active'", if_not_exists: true
  end

  def down
    # Reverse the changes
    remove_index :vectors, :category, if_exists: true
    remove_index :vectors, [ :category, :product_status_id ], if_exists: true

    remove_index :users, :email_address, if_exists: true
    add_index :users, :email_address, unique: true

    remove_index :carts, :user_id, if_exists: true
    add_index :carts, :user_id

    add_index :cart_items, :cart_id, if_not_exists: true

    remove_index :subscriptions, [ :user_id, :status ], if_exists: true
  end
end
