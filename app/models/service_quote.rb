class ServiceQuote < ApplicationRecord
  belongs_to :user, optional: true

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true, inclusion: { in: %w[pending contacted quoted converted declined] }

  scope :pending, -> { where(status: 'pending') }
  scope :contacted, -> { where(status: 'contacted') }
  scope :recent, -> { order(created_at: :desc) }

  # Serialize selected_services as JSON
  serialize :selected_services, coder: JSON

  before_create :generate_quote_number

  def contacted?
    contacted_at.present?
  end

  def quoted?
    quoted_at.present?
  end

  def converted?
    status == 'converted'
  end

  # Calculate total from selected services
  def calculate_estimated_total
    return 0 unless selected_services.is_a?(Array)

    selected_services.sum do |service|
      service['price'].to_f
    end
  end

  private

  def generate_quote_number
    self.quote_number = "SQ#{Date.current.strftime('%Y%m%d')}#{SecureRandom.hex(4).upcase}"
  end
end
