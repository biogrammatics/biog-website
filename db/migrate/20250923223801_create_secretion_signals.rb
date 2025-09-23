class CreateSecretionSignals < ActiveRecord::Migration[8.0]
  def change
    create_table :secretion_signals do |t|
      t.string :name, null: false
      t.text :sequence, null: false
      t.string :organism, default: 'Pichia pastoris'
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :secretion_signals, :organism
    add_index :secretion_signals, :active
  end
end
