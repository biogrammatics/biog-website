namespace :twilio do
  desc "Test Twilio SMS integration"
  task test: :environment do
    puts "Testing Twilio SMS integration..."

    # Check if credentials are present
    account_sid = Rails.application.credentials.dig(:twilio, :account_sid)
    auth_token = Rails.application.credentials.dig(:twilio, :auth_token)
    phone_number = Rails.application.credentials.dig(:twilio, :phone_number)

    if account_sid.blank? || auth_token.blank? || phone_number.blank?
      puts "❌ Missing Twilio credentials!"
      puts "   Account SID: #{'✓' if account_sid.present?}#{'✗' if account_sid.blank?}"
      puts "   Auth Token: #{'✓' if auth_token.present?}#{'✗' if auth_token.blank?}"
      puts "   Phone Number: #{'✓' if phone_number.present?}#{'✗' if phone_number.blank?}"
      puts "\nPlease add credentials using: rails credentials:edit"
      exit 1
    end

    puts "✓ All Twilio credentials are present"
    puts "  Account SID: #{account_sid[0..10]}..."
    puts "  Phone Number: #{phone_number}"

    # Test Twilio client initialization
    service = TwilioService.new
    puts "✓ TwilioService initialized successfully"

    # Ask for test phone number
    print "\nEnter a phone number to test SMS (format: +1234567890 or 1234567890): "
    test_phone = STDIN.gets.chomp

    if test_phone.blank?
      puts "No phone number provided, skipping SMS test"
      exit 0
    end

    # Send test SMS
    puts "Sending test SMS..."
    test_code = "123456"

    if service.send_otp_code(test_phone, test_code)
      puts "✅ Test SMS sent successfully!"
      puts "Check your phone for the verification code: #{test_code}"
    else
      puts "❌ Failed to send test SMS"
      puts "Check the Rails logs for error details"
    end
  end
end