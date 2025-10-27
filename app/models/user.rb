class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :custom_projects, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :phone_number, with: ->(p) { p&.gsub(/\D/, "") }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: :password_required?
  validates :phone_number, format: { with: /\A\d{10,15}\z/ }, allow_blank: true
  validates :otp_delivery_method, inclusion: { in: %w[totp sms] }

  # Encrypt sensitive 2FA fields for security
  encrypts :otp_secret, deterministic: false
  encrypts :otp_backup_codes, deterministic: false
  encrypts :otp_code, deterministic: false

  # Note: 2FA requirement for admins is enforced during authentication flow

  # TOTP setup
  attr_accessor :otp_plain_secret

  before_create :setup_otp_secret

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def admin?
    admin
  end

  def current_cart
    cart || create_cart!
  end

  def current_subscription
    subscriptions.active.first
  end

  def has_active_subscription?
    current_subscription&.active?
  end

  def default_billing_address
    addresses.billing.default_addresses.first
  end

  def default_shipping_address
    addresses.shipping.default_addresses.first
  end

  # Login tracking methods
  def last_login
    sessions.order(created_at: :desc).first
  end

  def last_login_at
    last_login&.created_at
  end

  def login_count
    sessions.count
  end

  def recent_logins(limit = 10)
    sessions.order(created_at: :desc).limit(limit)
  end

  # 2FA Methods
  def two_factor_required?
    admin? || two_factor_enabled?
  end

  def otp_provisioning_uri
    return unless otp_secret.present?

    totp = ROTP::TOTP.new(otp_secret, issuer: "BioGrammatics")
    totp.provisioning_uri(email_address)
  end

  def generate_qr_code
    return unless otp_provisioning_uri

    qrcode = RQRCode::QRCode.new(otp_provisioning_uri)
    qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 4,
      standalone: true,
      use_path: true
    ).html_safe
  end

  def validate_otp_code(code)
    return false if code.blank?

    if otp_delivery_method == "totp"
      validate_totp_code(code)
    else
      validate_sms_code(code)
    end
  end

  def validate_totp_code(code)
    return false unless otp_secret.present?

    totp = ROTP::TOTP.new(otp_secret)
    totp.verify(code, drift_behind: 30, drift_ahead: 30)
  end

  def validate_sms_code(code)
    return false unless otp_code.present? && otp_code_sent_at.present?

    # Code expires after 10 minutes
    return false if otp_code_sent_at < 10.minutes.ago

    ActiveSupport::SecurityUtils.secure_compare(otp_code, code)
  end

  def generate_otp_backup_codes
    codes = Array.new(10) { SecureRandom.hex(4).scan(/.{4}/).join("-") }
    self.otp_backup_codes = codes.to_json
    codes
  end

  def invalidate_otp_backup_code(code)
    return false unless otp_backup_codes.present?

    codes = JSON.parse(otp_backup_codes)
    if codes.include?(code)
      codes.delete(code)
      self.otp_backup_codes = codes.to_json
      save
      true
    else
      false
    end
  end

  def generate_sms_code
    self.otp_code = rand(100000..999999).to_s
    self.otp_code_sent_at = Time.current
    save
  end

  def send_sms_code
    return false unless phone_verified? && phone_number.present?

    generate_sms_code
    TwilioService.new.send_otp_code(phone_number, otp_code)
  end

  def enable_two_factor!
    update!(
      two_factor_enabled: true,
      two_factor_confirmed_at: Time.current,
      otp_required_for_login: true
    )
  end

  def disable_two_factor!
    update!(
      two_factor_enabled: false,
      two_factor_confirmed_at: nil,
      otp_required_for_login: false,
      otp_backup_codes: nil
    )
  end

  private

  def password_required?
    new_record? || password.present?
  end

  def setup_otp_secret
    self.otp_secret = ROTP::Base32.random
    self.otp_plain_secret = otp_secret
  end

  # Removed admin_requires_two_factor validation - handled in authentication flow
end
