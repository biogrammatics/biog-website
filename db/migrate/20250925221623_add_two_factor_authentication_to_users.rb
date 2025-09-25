class AddTwoFactorAuthenticationToUsers < ActiveRecord::Migration[8.0]
  def change
    # TOTP fields (for authenticator apps)
    add_column :users, :otp_secret, :string
    add_column :users, :otp_required_for_login, :boolean, default: false

    # SMS fields (for phone-based 2FA)
    add_column :users, :phone_number, :string
    add_column :users, :phone_verified, :boolean, default: false

    # 2FA configuration
    add_column :users, :otp_delivery_method, :string, default: 'totp' # 'totp' or 'sms'
    add_column :users, :two_factor_enabled, :boolean, default: false
    add_column :users, :two_factor_confirmed_at, :datetime

    # Backup codes (stored as encrypted JSON array)
    add_column :users, :otp_backup_codes, :text

    # Temporary OTP for SMS (expires quickly)
    add_column :users, :otp_code, :string
    add_column :users, :otp_code_sent_at, :datetime

    # Indexes for performance
    add_index :users, :otp_required_for_login
    add_index :users, :two_factor_enabled
    add_index :users, :phone_number
  end
end
