class Subscription < ApplicationRecord
  belongs_to :user
  has_many :subscription_vectors, dependent: :destroy
  has_many :vectors, through: :subscription_vectors

  validates :twist_username, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending active expired cancelled] }
  validates :onboarding_fee, presence: true, numericality: { greater_than: 0 }
  validates :minimum_prorated_fee, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(status: "active") }
  scope :pending, -> { where(status: "pending") }

  def active?
    status == "active" && renewal_date && renewal_date >= Date.current
  end

  def expired?
    status == "active" && renewal_date && renewal_date < Date.current
  end

  def days_until_renewal
    return 0 unless renewal_date
    (renewal_date - Date.current).to_i
  end

  def days_since_started
    return 0 unless started_at
    (Date.current - started_at.to_date).to_i
  end

  def calculate_prorated_amount(vector)
    return 0 unless vector.subscription_price && renewal_date && started_at

    days_remaining = days_until_renewal
    return minimum_prorated_fee if days_remaining <= 30 # Minimum fee for last 30 days

    total_days = 365 # Annual subscription
    prorated_amount = (vector.subscription_price * days_remaining) / total_days.to_f

    [ prorated_amount, minimum_prorated_fee ].max
  end

  def start_subscription!
    self.status = "active"
    self.started_at = Time.current
    self.renewal_date = 1.year.from_now.to_date
    save!
  end

  def add_vector(vector, prorated_amount = nil)
    prorated_amount ||= calculate_prorated_amount(vector)

    subscription_vectors.create!(
      vector: vector,
      added_at: Time.current,
      prorated_amount: prorated_amount
    )
  end

  def total_subscription_cost
    subscription_vectors.sum(:prorated_amount) || 0
  end
end
