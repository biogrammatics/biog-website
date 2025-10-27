class SmsSetupService
  attr_reader :user, :errors

  def initialize(user)
    @user = user
    @errors = []
  end

  # Send verification code to phone number
  def send_verification_code(phone_number)
    return false unless validate_phone_number(phone_number)

    user.phone_number = phone_number
    code = generate_verification_code
    user.otp_code = code
    user.otp_code_sent_at = Time.current

    unless user.save
      @errors << "Failed to save phone number"
      return false
    end

    if TwilioService.new.send_phone_verification(user.phone_number, code)
      true
    else
      @errors << "Failed to send verification code. Please check the phone number."
      false
    end
  end

  # Verify the phone code and enable SMS 2FA
  def verify_and_enable(otp_code)
    unless user.validate_sms_code(otp_code)
      @errors << "Invalid or expired code. Please try again."
      return false
    end

    ActiveRecord::Base.transaction do
      user.update!(
        phone_verified: true,
        otp_delivery_method: "sms",
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

  # Resend verification code
  def resend_verification_code
    return false unless user.phone_number.present?

    send_verification_code(user.phone_number)
  end

  private

  def generate_verification_code
    rand(100000..999999).to_s
  end

  def validate_phone_number(phone_number)
    if phone_number.blank?
      @errors << "Phone number cannot be blank"
      return false
    end

    # Basic phone number validation
    normalized = phone_number.gsub(/\D/, "")
    if normalized.length < 10 || normalized.length > 15
      @errors << "Phone number must be between 10 and 15 digits"
      return false
    end

    true
  end
end
