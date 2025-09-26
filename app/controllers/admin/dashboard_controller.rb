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

    if service.send_otp_code(phone_number, test_code)
      flash[:notice] = "Test SMS sent successfully to #{phone_number} with code: #{test_code}"
      redirect_to admin_test_sms_path
    else
      flash[:alert] = "Failed to send SMS. Check Twilio credentials and logs."
      render :test_sms, status: :unprocessable_entity
    end
  end
end