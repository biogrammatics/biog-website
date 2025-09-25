class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    @checkout = params[:checkout].present?
    @user = User.new  # For registration form
  end

  def create
    # Check if this is a registration (has user params) or login
    if params[:user].present?
      # Registration flow
      @user = User.new(user_params)
      if @user.save
        start_new_session_for @user
        transfer_session_cart_to_user(@user)
        redirect_to cart_path, notice: "Account created successfully! Please complete your checkout."
      else
        @checkout = params[:checkout].present?
        render :new, status: :unprocessable_entity
      end
    else
      # Login flow
      if user = User.authenticate_by(params.permit(:email_address, :password))
        # Check if this is an admin without 2FA - redirect to setup
        if user.admin? && !user.two_factor_enabled?
          start_new_session_for user
          transfer_session_cart_to_user(user)
          redirect_to setup_path, notice: "As an administrator, you must set up two-factor authentication to secure your account."
        # Check if 2FA is required and enabled
        elsif user.two_factor_required? && user.two_factor_enabled?
          # Store user ID in session for 2FA verification
          session[:pending_otp_user_id] = user.id
          redirect_to verify_path
        else
          start_new_session_for user
          transfer_session_cart_to_user(user)
          redirect_to after_authentication_url
        end
      else
        @checkout = params[:checkout].present?
        @user = User.new
        redirect_to new_session_path(checkout: @checkout), alert: "Try another email address or password."
      end
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :first_name, :last_name)
  end

  def transfer_session_cart_to_user(user)
    session_cart_service = SessionCartService.new(session)
    return if session_cart_service.empty?

    user_cart = user.current_cart
    cart_items = session_cart_service.cart_items

    cart_items.each do |cart_item|
      begin
        user_cart.add_item(cart_item.item, cart_item.quantity)
      rescue StandardError => e
        Rails.logger.warn "Failed to transfer cart item #{cart_item.session_key}: #{e.message}"
        next
      end
    end

    session_cart_service.clear
  end
end
