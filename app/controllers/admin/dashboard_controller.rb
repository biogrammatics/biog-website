class Admin::DashboardController < Admin::BaseController
  def index
    # Admin dashboard home
  end

  def test_sms
    # Show SMS testing form
  end

  def send_test_sms
    phone_number = params[:phone_number]
    test_code = rand(100000..999999).to_s

    if phone_number.blank?
      flash[:alert] = "Please enter a phone number"
      render :test_sms, status: :unprocessable_entity
      return
    end

    service = TwilioService.new
    result = service.send_otp_code(phone_number, test_code)

    if result[:success]
      flash[:notice] = "✅ SMS sent successfully to #{phone_number}! Code: #{test_code}, Message SID: #{result[:message_sid]}, Status: #{result[:status]}"
      redirect_to admin_test_sms_path
    else
      error_details = []
      error_details << "Error: #{result[:error]}" if result[:error]
      error_details << "Code: #{result[:code]}" if result[:code]
      error_details << "Details: #{result[:details]}" if result[:details]

      flash[:alert] = "❌ SMS failed: #{error_details.join(' | ')}"
      render :test_sms, status: :unprocessable_entity
    end
  end
end
