class CreatePathwaySelections < ActiveRecord::Migration[8.0]
  def change
    create_table :pathway_selections do |t|
      t.references :user, foreign_key: true
      t.string :session_id
      t.integer :step_number, null: false
      t.string :selection_type, null: false # 'diy' or 'service'
      t.references :service_package, foreign_key: true
      t.text :notes
      t.string :status, default: 'in_progress' # in_progress, completed, quoted

      t.timestamps
    end

    add_index :pathway_selections, :session_id
    add_index :pathway_selections, [:user_id, :status]
    add_index :pathway_selections, :status
    add_index :pathway_selections, :created_at
  end
end
