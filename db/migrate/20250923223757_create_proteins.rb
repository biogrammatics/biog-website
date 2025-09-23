class CreateProteins < ActiveRecord::Migration[8.0]
  def change
    create_table :proteins do |t|
      t.references :custom_project, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.text :amino_acid_sequence, null: false
      t.text :original_sequence
      t.string :secretion_signal
      t.string :n_terminal_tag
      t.string :c_terminal_tag
      t.decimal :molecular_weight, precision: 10, scale: 2
      t.text :dna_sequence
      t.integer :sequence_order, default: 1

      t.timestamps
    end

    add_index :proteins, [:custom_project_id, :sequence_order]
  end
end
