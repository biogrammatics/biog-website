class CreateCartItems < ActiveRecord::Migration[8.0]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.string :item_type, null: false
      t.integer :item_id, null: false
      t.integer :quantity, default: 1, null: false
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :cart_items, [ :item_type, :item_id ]
    add_index :cart_items, [ :cart_id, :item_type, :item_id ], unique: true
  end
end
