class TwilioService
  def initialize
    account_sid = Rails.application.credentials.dig(:twilio, :account_sid)
    auth_token = Rails.application.credentials.dig(:twilio, :auth_token)
    @from_phone = Rails.application.credentials.dig(:twilio, :phone_number)

    @client = Twilio::REST::Client.new(account_sid, auth_token) if account_sid && auth_token
  end

  def send_otp_code(to_phone, code)
    return false unless @client && @from_phone

    formatted_to = format_phone_number(to_phone)

    begin
      @client.messages.create(
        from: @from_phone,
        to: formatted_to,
        body: "Your BioGrammatics verification code is: #{code}. This code expires in 10 minutes."
      )
      true
    rescue Twilio::REST::TwilioError => e
      Rails.logger.error "Twilio SMS failed: #{e.message}"
      false
    end
  end

  def send_phone_verification(to_phone, code)
    return false unless @client && @from_phone

    formatted_to = format_phone_number(to_phone)

    begin
      @client.messages.create(
        from: @from_phone,
        to: formatted_to,
        body: "Your BioGrammatics phone verification code is: #{code}. Enter this code to verify your phone number."
      )
      true
    rescue Twilio::REST::TwilioError => e
      Rails.logger.error "Twilio phone verification failed: #{e.message}"
      false
    end
  end

  def send_two_factor_disabled_alert(to_phone)
    return false unless @client && @from_phone

    formatted_to = format_phone_number(to_phone)

    begin
      @client.messages.create(
        from: @from_phone,
        to: formatted_to,
        body: "Two-factor authentication has been disabled on your BioGrammatics account. If you didn't make this change, please contact support immediately."
      )
      true
    rescue Twilio::REST::TwilioError => e
      Rails.logger.error "Twilio alert failed: #{e.message}"
      false
    end
  end

  private

  def format_phone_number(phone)
    # Ensure phone number has country code (assuming US if not present)
    return phone if phone.start_with?("+")

    # Remove any non-digit characters
    cleaned = phone.gsub(/\D/, "")

    # Add US country code if it's a 10-digit number
    if cleaned.length == 10
      "+1#{cleaned}"
    else
      "+#{cleaned}"
    end
  end
end
