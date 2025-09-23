class SetDefaultCategoryForVectors < ActiveRecord::Migration[8.0]
  def up
    # Set default category for existing vectors without a category
    # Default to "Heterologous Protein Expression" as it's the most common use case
    execute <<-SQL
      UPDATE vectors
      SET category = 'Heterologous Protein Expression'
      WHERE category IS NULL OR category = ''
    SQL
  end

  def down
    # No need to reverse this as we're just setting defaults
  end
end
