class AddProteinExpressionFieldsToCustomProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :custom_projects, :amino_acid_sequence, :text
    add_column :custom_projects, :selected_vector_id, :integer
    add_column :custom_projects, :dna_sequence, :text
    add_column :custom_projects, :dna_sequence_approved, :boolean, default: false
    add_column :custom_projects, :codon_optimization_notes, :text
    add_column :custom_projects, :protein_name, :string
    add_column :custom_projects, :protein_molecular_weight, :decimal
    add_column :custom_projects, :protein_description, :text

    add_index :custom_projects, :selected_vector_id
  end
end
