class UpdateCustomProjectsConstraints < ActiveRecord::Migration[8.0]
  def up
    # Remove existing constraints
    remove_check_constraint :custom_projects, name: "custom_projects_status_check", if_exists: true
    remove_check_constraint :custom_projects, name: "custom_projects_project_type_check", if_exists: true
    
    # Add updated constraints with new values
    add_check_constraint :custom_projects, "status IN ('pending', 'in_progress', 'completed', 'cancelled', 'awaiting_approval', 'sequence_approved')", name: "custom_projects_status_check"
    add_check_constraint :custom_projects, "project_type IN ('strain_only', 'strain_and_testing', 'full_service', 'consultation', 'protein_expression') OR project_type IS NULL", name: "custom_projects_project_type_check"
  end

  def down
    # Remove updated constraints
    remove_check_constraint :custom_projects, name: "custom_projects_status_check", if_exists: true
    remove_check_constraint :custom_projects, name: "custom_projects_project_type_check", if_exists: true
    
    # Restore original constraints
    add_check_constraint :custom_projects, "status IN ('pending', 'in_progress', 'completed', 'cancelled')", name: "custom_projects_status_check"
    add_check_constraint :custom_projects, "project_type IN ('strain_only', 'strain_and_testing', 'full_service', 'consultation') OR project_type IS NULL", name: "custom_projects_project_type_check"
  end
end
