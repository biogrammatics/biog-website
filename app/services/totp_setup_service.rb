class TotpSetupService
  attr_reader :user, :errors

  def initialize(user)
    @user = user
    @errors = []
  end

  # Ensure user has an OTP secret
  def ensure_secret
    return true if user.otp_secret.present?

    user.setup_otp_secret
    user.save!
    true
  rescue ActiveRecord::RecordInvalid => e
    @errors << e.message
    false
  end

  # Generate QR code for TOTP setup
  def generate_qr_code
    ensure_secret
    user.generate_qr_code
  end

  # Get the plain text secret for manual entry
  def plain_secret
    user.otp_plain_secret || user.otp_secret
  end

  # Confirm TOTP setup with verification code
  def confirm(otp_code)
    unless user.validate_totp_code(otp_code)
      @errors << "Invalid code. Please try again."
      return false
    end

    ActiveRecord::Base.transaction do
      user.update!(
        otp_delivery_method: "totp",
        two_factor_enabled: true,
        two_factor_confirmed_at: Time.current,
        otp_required_for_login: true
      )

      # Generate backup codes
      user.generate_otp_backup_codes
      user.save!
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    @errors << e.message
    false
  end

  # Enable TOTP for user (called from admin setup)
  def enable_for_admin
    return false unless user.admin?

    ensure_secret
    true
  end
end
