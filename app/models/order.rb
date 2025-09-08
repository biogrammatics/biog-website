class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  STATUSES = %w[pending processing shipped delivered cancelled].freeze

  validates :order_number, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :subtotal, :shipping_cost, :tax_amount, :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_order_number, on: :create
  before_validation :set_ordered_at, on: :create

  scope :recent, -> { order(ordered_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }

  def self.pending
    by_status("pending")
  end

  def self.processing
    by_status("processing")
  end

  def display_status
    status.humanize
  end

  def can_be_cancelled?
    %w[pending processing].include?(status)
  end

  private

  def generate_order_number
    return if order_number.present?
    
    loop do
      self.order_number = "BO#{Date.current.strftime('%Y%m%d')}#{SecureRandom.hex(4).upcase}"
      break unless Order.exists?(order_number: order_number)
    end
  end

  def set_ordered_at
    self.ordered_at ||= Time.current
  end
end
