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
        start_new_session_for user
        transfer_session_cart_to_user(user)
        redirect_to after_authentication_url
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
    return unless session[:cart].present?

    session_cart = session[:cart]
    user_cart = user.current_cart

    session_cart.each do |key, item_data|
      item_type, item_id = key.split("_")

      begin
        case item_type
        when "Vector"
          item = Vector.find(item_id)
        when "PichiaStrain"
          item = PichiaStrain.find(item_id)
        else
          next
        end

        user_cart.add_item(item, item_data["quantity"])
      rescue ActiveRecord::RecordNotFound
        # Item no longer exists, skip it
        next
      end
    end

    # Clear session cart after transfer
    session[:cart] = {}
  end
end
