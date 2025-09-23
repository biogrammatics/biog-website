class Admin::BaseController < ApplicationController
  before_action :require_admin!

  private

  # Common error handling for admin controllers
  def handle_record_not_found
    redirect_to admin_root_path, alert: "Record not found."
  end

  # Standard success notice for admin actions
  def success_notice(action, resource_name)
    "#{resource_name.capitalize} was successfully #{action}."
  end

  # Standard error alert for admin actions
  def error_alert(action, resource_name)
    "Failed to #{action} #{resource_name.downcase}. Please try again."
  end

  # Helper for safe parameter extraction
  def extract_permitted_params(params_key, permitted_attributes)
    params.require(params_key).permit(*permitted_attributes)
  rescue ActionController::ParameterMissing => e
    {}
  end

  # Common pagination settings
  def default_per_page
    25
  end

  # Standard ordering for admin indexes
  def default_order
    :name
  end

  # Check if user can perform destructive actions
  def can_perform_destructive_action?
    Current.user&.admin? && !Rails.env.production? ||
    Current.user&.admin? && params[:confirm] == "yes"
  end
end
