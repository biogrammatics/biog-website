class AccountController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = Current.user
    @subscriptions = @user.subscriptions.includes(subscription_vectors: :vector).order(created_at: :desc)
    @current_subscription = @user.current_subscription
    @cart_items = @user.current_cart.cart_items.includes(:item)
    @custom_projects = @user.custom_projects.order(created_at: :desc)
    @orders = @user.orders.includes(:order_items).order(created_at: :desc).limit(10)
    @billing_address = @user.default_billing_address
    @shipping_address = @user.default_shipping_address
    @saved_addresses = @user.addresses.order(created_at: :desc)
  end

  private

  def authenticate_user!
    unless authenticated?
      redirect_to new_session_path, alert: "Please sign in to access your account."
    end
  end
end
