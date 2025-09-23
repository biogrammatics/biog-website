class AddOptionalServicesToCustomProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :custom_projects, :copy_number_determination, :boolean, default: false
    add_column :custom_projects, :glycerol_stocks, :boolean, default: false
    add_column :custom_projects, :custom_strain_name, :string
    add_column :custom_projects, :delivery_format, :string, default: 'plate'
  end
end
