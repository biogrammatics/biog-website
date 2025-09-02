class CreateVectors < ActiveRecord::Migration[8.0]
  def change
    create_table :vectors do |t|
      t.string :name, null: false
      t.text :description
      t.string :category
      t.boolean :available_for_sale, default: true
      t.boolean :available_for_subscription, default: true
      t.decimal :sale_price, precision: 10, scale: 2
      t.decimal :subscription_price, precision: 10, scale: 2
      t.references :promoter, null: true, foreign_key: true
      t.references :selection_marker, null: true, foreign_key: true
      t.references :vector_type, null: true, foreign_key: true
      t.boolean :has_lox_sites, default: false
      t.integer :vector_size
      t.references :host_organism, null: true, foreign_key: true
      t.boolean :has_files, default: false
      t.string :file_version
      t.text :features
      t.references :product_status, null: false, foreign_key: true
      t.timestamps
    end

    add_index :vectors, :name
    add_index :vectors, :available_for_sale
    add_index :vectors, :available_for_subscription
  end
end
