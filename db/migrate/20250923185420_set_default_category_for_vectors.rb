class SetDefaultCategoryForVectors < ActiveRecord::Migration[8.0]
  def up
    # Set default category for existing vectors without a category
    # Default to "Heterologous Protein Expression" as it's the most common use case
    Vector.where(category: nil).update_all(category: "Heterologous Protein Expression")
    Vector.where(category: "").update_all(category: "Heterologous Protein Expression")
  end

  def down
    # No need to reverse this as we're just setting defaults
  end
end
