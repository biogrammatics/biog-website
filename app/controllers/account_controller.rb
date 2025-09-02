class AccountController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @user = Current.user
    @subscriptions = @user.subscriptions.includes(:subscription_vectors => :vector).order(created_at: :desc)
    @current_subscription = @user.current_subscription
    @cart_items = @user.current_cart.cart_items.includes(:item)
  end

  private

  def authenticate_user!
    unless authenticated?
      redirect_to new_session_path, alert: "Please sign in to access your account."
    end
  end
end
