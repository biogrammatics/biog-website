class CreateServicePackages < ActiveRecord::Migration[8.0]
  def change
    create_table :service_packages do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :step_number, null: false
      t.text :description
      t.text :diy_option
      t.text :service_option
      t.text :diy_challenges
      t.text :service_benefits
      t.text :whats_included
      t.decimal :estimated_price, precision: 10, scale: 2
      t.string :estimated_turnaround
      t.boolean :active, default: true, null: false
      t.integer :position

      t.timestamps
    end

    add_index :service_packages, :slug, unique: true
    add_index :service_packages, :step_number
    add_index :service_packages, :active
    add_index :service_packages, :position
  end
end
