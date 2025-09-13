class Vector < ApplicationRecord
  belongs_to :promoter, optional: true
  belongs_to :selection_marker, optional: true
  belongs_to :vector_type, optional: true
  belongs_to :host_organism, optional: true
  belongs_to :product_status
  has_many :subscription_vectors, dependent: :destroy
  has_many :subscriptions, through: :subscription_vectors

  has_many_attached :files

  validates :name, presence: true, uniqueness: true
  validates :sale_price, presence: true, if: :available_for_sale?
  validates :subscription_price, presence: true, if: :available_for_subscription?

  before_destroy :check_if_can_be_deleted

  scope :available_for_sale, -> { where(available_for_sale: true) }
  scope :available_for_subscription, -> { where(available_for_subscription: true) }
  scope :active, -> { joins(:product_status).where(product_statuses: { is_available: true }) }
  scope :heterologous_expression, -> { where(category: "Heterologous Protein Expression") }
  scope :genome_engineering, -> { where(category: "Genome Engineering") }

  CATEGORIES = [
    "Heterologous Protein Expression",
    "Genome Engineering"
  ].freeze

  def available?
    product_status&.is_available?
  end

  def snapgene_file
    files.find { |file| file.filename.to_s.include?(".dna") }
  end

  def genbank_file
    files.find { |file| file.filename.to_s.include?(".gb") }
  end

  # Check if this vector has been purchased by any customer
  def has_been_purchased?
    return false unless defined?(OrderItem) && OrderItem.table_exists?

    OrderItem.where(item_type: "Vector", item_id: id)
             .joins(:order)
             .where(orders: { status: "completed" })
             .exists?
  rescue ActiveRecord::StatementInvalid
    false
  end

  # Get count of customers who purchased this vector
  def purchase_count
    return 0 unless defined?(OrderItem) && OrderItem.table_exists?

    OrderItem.where(item_type: "Vector", item_id: id)
             .joins(:order)
             .where(orders: { status: "completed" })
             .count
  rescue ActiveRecord::StatementInvalid
    0
  end

  # Check if vector is included in any subscriptions
  def in_subscriptions?
    subscription_vectors.exists?
  end

  # Prevent deletion if purchased
  def can_be_deleted?
    !has_been_purchased? && !in_subscriptions?
  end

  private

  def check_if_can_be_deleted
    if has_been_purchased?
      errors.add(:base, "Cannot delete vector that has been purchased by customers")
      throw(:abort)
    end
    if in_subscriptions?
      errors.add(:base, "Cannot delete vector that is included in subscriptions")
      throw(:abort)
    end
  end
end
