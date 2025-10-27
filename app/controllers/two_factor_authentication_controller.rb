class TwoFactorAuthenticationController < ApplicationController
  before_action :require_authentication, except: [ :verify, :verify_code, :resend_code ]
  before_action :require_pending_otp, only: [ :verify, :verify_code, :resend_code ]
  rate_limit to: 5, within: 1.minute, only: [ :verify_code ],
             with: -> { redirect_to verify_path, alert: "Too many attempts. Please try again later." }

  def setup
    @user = Current.user

    # Ensure OTP secret exists (for users created before 2FA system)
    unless @user.otp_secret.present?
      @user.update!(otp_secret: ROTP::Base32.random)
    end

    # Prevent admins from accessing other pages without setting up 2FA
    if @user.admin? && !@user.two_factor_enabled?
      session[:admin_needs_2fa] = true
    end
  end

  def enable_totp
    @user = Current.user
    service = TotpSetupService.new(@user)

    service.ensure_secret
    @qr_code = service.generate_qr_code
    @secret = service.plain_secret
  end

  def confirm_totp
    @user = Current.user
    service = TotpSetupService.new(@user)

    if service.confirm(params[:otp_code])
      flash[:notice] = "Two-factor authentication has been enabled successfully!"
      session[:show_backup_codes] = true
      redirect_to backup_codes_path
    else
      flash.now[:alert] = service.errors.join(", ")
      @qr_code = service.generate_qr_code
      @secret = service.plain_secret
      render :enable_totp, status: :unprocessable_entity
    end
  end

  def enable_sms
    @user = Current.user
  end

  def verify_phone
    @user = Current.user
    service = SmsSetupService.new(@user)

    if service.send_verification_code(params[:phone_number])
      flash[:notice] = "Verification code sent to #{params[:phone_number]}"
      redirect_to confirm_phone_path
    else
      flash[:alert] = service.errors.join(", ")
      redirect_to enable_sms_path
    end
  end

  def confirm_phone
    @user = Current.user
  end

  def verify_phone_code
    @user = Current.user
    service = SmsSetupService.new(@user)

    if service.verify_and_enable(params[:otp_code])
      flash[:notice] = "Two-factor authentication via SMS has been enabled successfully!"
      session[:show_backup_codes] = true
      redirect_to backup_codes_path
    else
      flash.now[:alert] = service.errors.join(", ")
      render :confirm_phone, status: :unprocessable_entity
    end
  end

  def backup_codes
    @user = Current.user
    service = BackupCodeService.new(@user)

    @backup_codes = service.get_codes_for_display(session)
    redirect_to account_path unless @backup_codes
  end

  def regenerate_backup_codes
    @user = Current.user
    service = BackupCodeService.new(@user)

    @backup_codes = service.regenerate
    if @backup_codes
      flash[:notice] = "New backup codes have been generated. Please save them securely."
      render :backup_codes
    else
      flash[:alert] = service.errors.join(", ")
      redirect_to account_path
    end
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
