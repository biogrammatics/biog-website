class AddSnapGeneFileToVectors < ActiveRecord::Migration[8.0]
  def change
    # Add columns for SnapGene file information
    add_column :vectors, :snapgene_file_name, :string
    add_column :vectors, :snapgene_file_size, :integer
    add_column :vectors, :snapgene_uploaded_at, :datetime
  end
end
