class CreateServiceQuotes < ActiveRecord::Migration[8.0]
  def change
    create_table :service_quotes do |t|
      t.references :user, foreign_key: true
      t.string :session_id
      t.string :quote_number
      t.string :email_address, null: false
      t.string :full_name
      t.string :organization
      t.string :phone_number

      # Project details
      t.string :project_name
      t.string :target_protein_name
      t.text :protein_tags
      t.text :special_requirements
      t.text :notes

      # Selected services
      t.json :selected_services # Array of service package IDs and details
      t.decimal :estimated_total, precision: 10, scale: 2

      # Status tracking
      t.string :status, default: 'pending' # pending, contacted, quoted, converted, declined
      t.datetime :contacted_at
      t.datetime :quoted_at
      t.text :admin_notes

      t.timestamps
    end

    add_index :service_quotes, :quote_number, unique: true
    add_index :service_quotes, :email_address
    add_index :service_quotes, :status
    add_index :service_quotes, :created_at
    add_index :service_quotes, [ :user_id, :status ]
    add_index :service_quotes, :session_id
  end
end
