class AddForeignKeyToCustomProjects < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :custom_projects, :expression_vectors, column: :selected_vector_id
  end
end
