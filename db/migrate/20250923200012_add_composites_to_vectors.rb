class AddCompositesToVectors < ActiveRecord::Migration[8.0]
  def change
    # Add composite index for common filtering patterns
    add_index :vectors, [ :available_for_sale, :category, :product_status_id ],
              name: "index_vectors_on_sale_category_status",
              if_not_exists: true

    add_index :vectors, [ :available_for_subscription, :category, :product_status_id ],
              name: "index_vectors_on_subscription_category_status",
              if_not_exists: true

    # Add index for vectors with promoter grouping
    add_index :vectors, [ :category, :promoter_id, :product_status_id ],
              name: "index_vectors_on_category_promoter_status",
              if_not_exists: true
  end
end
