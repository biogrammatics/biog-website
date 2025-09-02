class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :twist_username, null: false
      t.decimal :onboarding_fee, precision: 8, scale: 2, default: 300.00
      t.string :status, default: 'pending', null: false
      t.datetime :started_at
      t.date :renewal_date
      t.decimal :minimum_prorated_fee, precision: 8, scale: 2, default: 50.00

      t.timestamps
    end

    add_index :subscriptions, :status
  end
end
