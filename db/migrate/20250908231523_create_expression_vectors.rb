class CreateExpressionVectors < ActiveRecord::Migration[8.0]
  def change
    create_table :expression_vectors do |t|
      t.string :name, null: false
      t.text :description
      t.string :promoter, null: false
      t.string :drug_selection, null: false
      t.text :features
      t.decimal :price, precision: 10, scale: 2
      t.boolean :available, default: true
      t.string :vector_type, default: 'protein_expression'
      t.string :backbone
      t.string :cloning_sites
      t.text :additional_notes

      t.timestamps
    end

    add_index :expression_vectors, :available
    add_index :expression_vectors, :vector_type
  end
end
