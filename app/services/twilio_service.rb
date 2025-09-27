class TwilioService
  def initialize
    @account_sid = Rails.application.credentials.dig(:twilio, :account_sid)
    @auth_token = Rails.application.credentials.dig(:twilio, :auth_token)
    @from_phone = Rails.application.credentials.dig(:twilio, :phone_number)

    Rails.logger.info "TwilioService initialized with account_sid: #{@account_sid ? "#{@account_sid[0..10]}..." : 'missing'}, from_phone: #{@from_phone || 'missing'}"

    @client = Twilio::REST::Client.new(@account_sid, @auth_token) if @account_sid && @auth_token
  end

  def send_otp_code(to_phone, code)
    Rails.logger.info "Attempting to send SMS - From: #{@from_phone}, To: #{to_phone}, Client present: #{@client.present?}"

    return { success: false, error: "Twilio client not initialized" } unless @client && @from_phone

    formatted_to = format_phone_number(to_phone)
    Rails.logger.info "Formatted phone number: #{formatted_to}"

    begin
      message = @client.messages.create(
        from: @from_phone,
        to: formatted_to,
        body: "Your BioGrammatics verification code is: #{code}. This code expires in 10 minutes."
      )

      Rails.logger.info "Twilio SMS sent successfully - Message SID: #{message.sid}, Status: #{message.status}"
      { success: true, message_sid: message.sid, status: message.status }
    rescue Twilio::REST::TwilioError => e
      Rails.logger.error "Twilio SMS failed - Error Code: #{e.code}, Message: #{e.message}, Details: #{e.details}"
      { success: false, error: e.message, code: e.code, details: e.details }
    rescue => e
      Rails.logger.error "Unexpected error sending SMS: #{e.class}: #{e.message}"
      { success: false, error: "Unexpected error: #{e.message}" }
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
