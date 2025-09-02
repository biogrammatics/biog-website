class CreateSubscriptionVectors < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_vectors do |t|
      t.references :subscription, null: false, foreign_key: true
      t.references :vector, null: false, foreign_key: true
      t.datetime :added_at, null: false
      t.decimal :prorated_amount, precision: 8, scale: 2

      t.timestamps
    end
    
    add_index :subscription_vectors, [:subscription_id, :vector_id], unique: true
    add_index :subscription_vectors, :added_at
  end
end
