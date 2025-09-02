class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: :password_required?

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

  private

  def password_required?
    new_record? || password.present?
  end
end
