class ChangeCustomProjectsToUseVectors < ActiveRecord::Migration[8.0]
  def up
    # Remove the foreign key constraint to expression_vectors
    if foreign_key_exists?(:custom_projects, :expression_vectors)
      remove_foreign_key :custom_projects, :expression_vectors
    end

    # Add foreign key constraint to vectors table instead
    add_foreign_key :custom_projects, :vectors, column: :selected_vector_id
  end

  def down
    # Remove the foreign key constraint to vectors
    if foreign_key_exists?(:custom_projects, :vectors)
      remove_foreign_key :custom_projects, :vectors
    end

    # Add back the foreign key constraint to expression_vectors
    add_foreign_key :custom_projects, :expression_vectors, column: :selected_vector_id
  end
end
