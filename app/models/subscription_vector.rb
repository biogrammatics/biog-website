class SubscriptionVector < ApplicationRecord
  belongs_to :subscription
  belongs_to :vector

  validates :added_at, presence: true
  validates :prorated_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :subscription_id, uniqueness: { scope: :vector_id, message: "Vector already added to this subscription" }

  scope :ordered_by_date, -> { order(:added_at) }
  scope :recent, -> { where("added_at >= ?", 30.days.ago) }

  def days_in_subscription
    return 0 unless added_at && subscription.renewal_date
    (subscription.renewal_date - added_at.to_date).to_i
  end
end
