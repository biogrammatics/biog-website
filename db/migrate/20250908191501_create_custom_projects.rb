class CreateCustomProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :custom_projects do |t|
      t.references :user, null: false, foreign_key: true
      t.string :project_name, null: false
      t.string :project_type
      t.text :description
      t.boolean :strain_generation, default: false
      t.boolean :expression_testing, default: false
      t.string :status, default: 'pending'
      t.text :notes
      t.decimal :estimated_cost, precision: 10, scale: 2
      t.date :estimated_completion_date

      t.timestamps
    end
    
    add_index :custom_projects, :status
    add_index :custom_projects, :project_type
  end
end
