class BackupCodeService
  attr_reader :user, :errors

  def initialize(user)
    @user = user
    @errors = []
  end

  # Get backup codes (only if session flag is set)
  def get_codes_for_display(session)
    return nil unless session[:show_backup_codes]

    codes = parse_backup_codes
    session.delete(:show_backup_codes)
    codes
  end

  # Generate new backup codes
  def regenerate
    codes = user.generate_otp_backup_codes

    if user.save
      codes
    else
      @errors << "Failed to save backup codes"
      nil
    end
  end

  # Validate a backup code
  def validate_code(code)
    user.validate_backup_code(code)
  end

  # Get remaining backup codes count
  def remaining_count
    codes = parse_backup_codes
    return 0 unless codes

    codes.count { |code| code.present? }
  end

  # Check if user has backup codes
  def has_codes?
    user.otp_backup_codes.present?
  end

  private

  def parse_backup_codes
    return [] unless user.otp_backup_codes.present?

    JSON.parse(user.otp_backup_codes)
  rescue JSON::ParserError
    @errors << "Failed to parse backup codes"
    []
  end
end
