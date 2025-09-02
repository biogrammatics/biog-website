class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def require_admin!
    unless Current.user&.admin?
      redirect_to root_path, alert: "Access denied. Administrator privileges required."
    end
  end

  def admin_signed_in?
    Current.user&.admin?
  end
  helper_method :admin_signed_in?
end
