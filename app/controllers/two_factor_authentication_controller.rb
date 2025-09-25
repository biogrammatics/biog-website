class TwoFactorAuthenticationController < ApplicationController
  before_action :require_authentication
  before_action :require_pending_otp, only: [ :verify, :verify_code ]
  rate_limit to: 5, within: 1.minute, only: [ :verify_code ],
             with: -> { redirect_to verify_path, alert: "Too many attempts. Please try again later." }

  def setup
    @user = Current.user
  end

  def enable_totp
    @user = Current.user

    # Generate new secret if not present
    unless @user.otp_secret.present?
      @user.setup_otp_secret
      @user.save!
    end

    @qr_code = @user.generate_qr_code
    @secret = @user.otp_plain_secret || @user.otp_secret
  end

  def confirm_totp
    @user = Current.user
    code = params[:otp_code]

    if @user.validate_totp_code(code)
      @user.update!(
        otp_delivery_method: "totp",
        two_factor_enabled: true,
        two_factor_confirmed_at: Time.current,
        otp_required_for_login: true
      )

      # Generate backup codes
      backup_codes = @user.generate_otp_backup_codes
      @user.save!

      flash[:notice] = "Two-factor authentication has been enabled successfully!"
      session[:show_backup_codes] = true
      redirect_to backup_codes_path
    else
      flash.now[:alert] = "Invalid code. Please try again."
      @qr_code = @user.generate_qr_code
      @secret = @user.otp_secret
      render :enable_totp, status: :unprocessable_entity
    end
  end

  def enable_sms
    @user = Current.user
  end

  def verify_phone
    @user = Current.user
    phone = params[:phone_number]

    if phone.present?
      @user.phone_number = phone

      # Generate and send verification code
      code = rand(100000..999999).to_s
      @user.otp_code = code
      @user.otp_code_sent_at = Time.current
      @user.save!

      if TwilioService.new.send_phone_verification(@user.phone_number, code)
        flash[:notice] = "Verification code sent to #{phone}"
        redirect_to confirm_phone_path
      else
        flash[:alert] = "Failed to send verification code. Please check the phone number."
        redirect_to enable_sms_path
      end
    else
      flash[:alert] = "Please enter a valid phone number"
      redirect_to enable_sms_path
    end
  end

  def confirm_phone
    @user = Current.user
  end

  def verify_phone_code
    @user = Current.user
    code = params[:otp_code]

    if @user.validate_sms_code(code)
      @user.update!(
        phone_verified: true,
        otp_delivery_method: "sms",
        two_factor_enabled: true,
        two_factor_confirmed_at: Time.current,
        otp_required_for_login: true
      )

      # Generate backup codes
      backup_codes = @user.generate_otp_backup_codes
      @user.save!

      flash[:notice] = "Two-factor authentication via SMS has been enabled successfully!"
      session[:show_backup_codes] = true
      redirect_to backup_codes_path
    else
      flash.now[:alert] = "Invalid or expired code. Please try again."
      render :confirm_phone, status: :unprocessable_entity
    end
  end

  def backup_codes
    @user = Current.user

    # Only show codes once after setup
    if session[:show_backup_codes]
      @backup_codes = JSON.parse(@user.otp_backup_codes)
      session.delete(:show_backup_codes)
    else
      redirect_to account_path
    end
  end

  def regenerate_backup_codes
    @user = Current.user
    @backup_codes = @user.generate_otp_backup_codes
    @user.save!

    flash[:notice] = "New backup codes have been generated. Please save them securely."
    render :backup_codes
  end

  def disable
    @user = Current.user
  end

  def confirm_disable
    @user = Current.user

    if @user.authenticate(params[:password])
      # Admin check - prevent disabling if admin
      if @user.admin?
        flash[:alert] = "Administrators cannot disable two-factor authentication."
        redirect_to account_path
        return
      end

      # Send notification if SMS was enabled
      if @user.otp_delivery_method == "sms" && @user.phone_verified?
        TwilioService.new.send_two_factor_disabled_alert(@user.phone_number)
      end

      @user.disable_two_factor!
      flash[:notice] = "Two-factor authentication has been disabled."
      redirect_to account_path
    else
      flash.now[:alert] = "Incorrect password."
      render :disable, status: :unprocessable_entity
    end
  end

  # Called during login flow
  def verify
    @user = session[:pending_otp_user_id] ? User.find(session[:pending_otp_user_id]) : nil

    unless @user
      redirect_to new_session_path, alert: "Session expired. Please login again."
      return
    end

    # Send SMS code if using SMS method
    if @user.otp_delivery_method == "sms"
      @user.send_sms_code
      flash.now[:notice] = "Verification code sent to your phone."
    end
  end

  def verify_code
    @user = User.find(session[:pending_otp_user_id])
    code = params[:otp_code]

    # Check if it's a backup code first
    if code.include?("-") && @user.invalidate_otp_backup_code(code)
      complete_two_factor_login
    elsif @user.validate_otp_code(code)
      complete_two_factor_login
    else
      flash.now[:alert] = "Invalid code. Please try again."
      render :verify, status: :unprocessable_entity
    end
  end

  def resend_code
    @user = User.find(session[:pending_otp_user_id])

    if @user.otp_delivery_method == "sms"
      if @user.send_sms_code
        flash[:notice] = "New verification code sent to your phone."
      else
        flash[:alert] = "Failed to send code. Please try again."
      end
    else
      flash[:alert] = "Resending codes is only available for SMS authentication."
    end

    redirect_to verify_path
  end

  private

  def require_pending_otp
    unless session[:pending_otp_user_id]
      redirect_to new_session_path, alert: "Please login first."
    end
  end

  def complete_two_factor_login
    @user = User.find(session[:pending_otp_user_id])

    # Clear pending OTP session
    session.delete(:pending_otp_user_id)

    # Complete login
    start_new_session_for @user

    # Transfer cart if needed (from SessionsController logic)
    if defined?(transfer_session_cart_to_user)
      transfer_session_cart_to_user(@user)
    end

    redirect_to after_authentication_url, notice: "Successfully logged in with two-factor authentication."
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      reset_session
      session_id = session.id
      cookies.signed.permanent[:session_id] = { value: session_id, httponly: true, same_site: :lax }
    end
  end

  def after_authentication_url
    session[:return_to_after_authentication] || root_url
  end
end
