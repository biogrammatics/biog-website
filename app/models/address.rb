class Address < ApplicationRecord
  belongs_to :user

  ADDRESS_TYPES = %w[billing shipping].freeze

  validates :address_type, presence: true, inclusion: { in: ADDRESS_TYPES }
  validates :first_name, :last_name, :address_line_1, :city, :country, presence: true
  validates :phone, presence: true, format: { with: /\A[\d\-\(\)\s\+\.]+\z/ }

  # State/Province required for US and Canada
  validates :state, presence: true, if: :north_american_country?

  # Postal code validation based on country
  validates :postal_code, presence: true
  validates :postal_code, format: { with: /\A\d{5}(-\d{4})?\z/, message: "should be in format 12345 or 12345-6789" }, if: :us_address?
  validates :postal_code, format: { with: /\A[A-Z]\d[A-Z]\s?\d[A-Z]\d\z/i, message: "should be in format A1A 1A1" }, if: :canadian_address?

  scope :billing, -> { where(address_type: "billing") }
  scope :shipping, -> { where(address_type: "shipping") }
  scope :default_addresses, -> { where(is_default: true) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def full_address
    lines = [ address_line_1 ]
    lines << address_line_2 if address_line_2.present?
    lines << "#{city}, #{state} #{postal_code}"
    lines << country if country != "United States"
    lines.join("\n")
  end

  def display_name
    name = full_name
    name += " (#{company})" if company.present?
    name
  end

  # Ensure only one default address per type per user
  def set_as_default!
    transaction do
      user.addresses.where(address_type: address_type).update_all(is_default: false)
      update!(is_default: true)
    end
  end

  private

  def us_address?
    country == "United States"
  end

  def canadian_address?
    country == "Canada"
  end

  def north_american_country?
    [ "United States", "Canada" ].include?(country)
  end
end
