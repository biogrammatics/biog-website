class ApplicationController < ActionController::Base
  include Authentication
  helper CookiesHelper

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

  # Cart helper methods for navigation
  def current_cart_items_count
    if authenticated?
      Current.user.current_cart.total_items
    else
      session_cart = session[:cart] || {}
      session_cart.sum { |key, item_data| item_data["quantity"] || 0 }
    end
  end
  helper_method :current_cart_items_count

  def has_cart_items?
    current_cart_items_count > 0
  end
  helper_method :has_cart_items?
end
