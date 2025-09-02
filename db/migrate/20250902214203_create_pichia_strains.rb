class CreatePichiaStrains < ActiveRecord::Migration[8.0]
  def change
    create_table :pichia_strains do |t|
      t.string :name, null: false
      t.text :description
      t.references :strain_type, null: true, foreign_key: true
      t.text :genotype
      t.text :phenotype
      t.text :advantages
      t.text :applications
      t.decimal :sale_price, precision: 10, scale: 2
      t.string :availability
      t.text :shipping_requirements
      t.text :storage_conditions
      t.string :viability_period
      t.text :culture_media
      t.text :growth_conditions
      t.text :citations
      t.boolean :has_files, default: false
      t.text :file_notes
      t.references :product_status, null: false, foreign_key: true
      t.timestamps
    end

    add_index :pichia_strains, :name
    add_index :pichia_strains, :availability
  end
end
