class AddFastaFileToCustomProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :custom_projects, :fasta_processed, :boolean, default: false
    add_column :custom_projects, :fasta_processing_notes, :text
  end
end
