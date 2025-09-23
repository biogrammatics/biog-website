class CreateProteinTags < ActiveRecord::Migration[8.0]
  def change
    create_table :protein_tags do |t|
      t.string :name, null: false
      t.text :sequence, null: false
      t.string :tag_type, null: false # 'n_terminal' or 'c_terminal'
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :protein_tags, :tag_type
    add_index :protein_tags, :active
  end
end
