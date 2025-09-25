class ApplicationController < ActionController::Base
  include Authentication
  helper CookiesHelper

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :enforce_admin_2fa_setup

  private

  def enforce_admin_2fa_setup
    return unless authenticated?
    return if request.path.start_with?("/two_factor") || request.path.start_with?("/session")

    if Current.user.admin? && !Current.user.two_factor_enabled?
      redirect_to setup_path, alert: "You must complete two-factor authentication setup to continue."
    end
  end

  def require_admin!
    unless Current.user&.admin?
      redirect_to root_path, alert: "Access denied. Administrator privileges required."
    end
  end

  def admin_signed_in?
    Current.user&.admin?
  end
  helper_method :admin_signed_in?

  # Cart helper methods for navigation
  def current_cart_items_count
    if authenticated?
      Current.user.current_cart.total_items
    else
      SessionCartService.new(session).total_items
    end
  end
  helper_method :current_cart_items_count

  def has_cart_items?
    current_cart_items_count > 0
  end
  helper_method :has_cart_items?
end
