module VectorPricing
  extend ActiveSupport::Concern

  included do
    validates :sale_price, presence: true, if: :available_for_sale?
    validates :subscription_price, presence: true, if: :available_for_subscription?

    scope :available_for_sale, -> { where(available_for_sale: true) }
    scope :available_for_subscription, -> { where(available_for_subscription: true) }
  end

  # Check if vector is available for purchase
  def available?
    product_status&.is_available?
  end

  # Format price for display
  def formatted_price
    if available_for_sale? && sale_price
      "$#{sale_price.to_f}"
    else
      "Contact for pricing"
    end
  end

  # Getter for backward compatibility
  def price
    sale_price
  end

  # Check if vector has been purchased by any customer
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

  # Prevent deletion if purchased or in subscriptions
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