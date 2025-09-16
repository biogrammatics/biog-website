class DropExpressionVectors < ActiveRecord::Migration[8.0]
  def up
    # Drop the expression_vectors table as it's no longer needed
    drop_table :expression_vectors
  end

  def down
    # Recreate the expression_vectors table structure if we need to rollback
    create_table :expression_vectors do |t|
      t.string :name, null: false
      t.text :description
      t.string :promoter, null: false
      t.string :drug_selection, null: false
      t.text :features
      t.decimal :price
      t.boolean :available
      t.string :vector_type
      t.string :backbone
      t.string :cloning_sites
      t.text :additional_notes
      t.timestamps
    end

    add_index :expression_vectors, :name, unique: true
    add_index :expression_vectors, :vector_type
    add_index :expression_vectors, :available
  end
end
