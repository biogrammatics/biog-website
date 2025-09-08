class Address < ApplicationRecord
  belongs_to :user

  ADDRESS_TYPES = %w[billing shipping].freeze

  validates :address_type, presence: true, inclusion: { in: ADDRESS_TYPES }
  validates :first_name, :last_name, :address_line_1, :city, :state, :postal_code, :country, presence: true
  validates :phone, presence: true, format: { with: /\A[\d\-\(\)\s\+\.]+\z/ }
  validates :postal_code, format: { with: /\A\d{5}(-\d{4})?\z/, message: "should be in format 12345 or 12345-6789" }

  scope :billing, -> { where(address_type: "billing") }
  scope :shipping, -> { where(address_type: "shipping") }
  scope :default_addresses, -> { where(is_default: true) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def full_address
    lines = [address_line_1]
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
end
