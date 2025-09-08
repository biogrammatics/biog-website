class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :order_number
      t.string :status
      t.decimal :subtotal
      t.decimal :shipping_cost
      t.decimal :tax_amount
      t.decimal :total_amount
      t.text :billing_address
      t.text :shipping_address
      t.text :notes
      t.datetime :ordered_at

      t.timestamps
    end
  end
end
