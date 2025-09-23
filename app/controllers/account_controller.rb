class AccountController < ApplicationController
  before_action :require_authentication

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
end
