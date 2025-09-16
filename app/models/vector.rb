class Vector < ApplicationRecord
  belongs_to :promoter, optional: true
  belongs_to :selection_marker, optional: true
  belongs_to :vector_type, optional: true
  belongs_to :host_organism, optional: true
  belongs_to :product_status
  has_many :subscription_vectors, dependent: :destroy
  has_many :subscriptions, through: :subscription_vectors
  has_many :custom_projects, foreign_key: :selected_vector_id, dependent: :nullify

  has_many_attached :files
  has_one_attached :map_image

  validates :name, presence: true, uniqueness: true
  validates :sale_price, presence: true, if: :available_for_sale?
  validates :subscription_price, presence: true, if: :available_for_subscription?

  before_destroy :check_if_can_be_deleted

  scope :available_for_sale, -> { where(available_for_sale: true) }
  scope :available_for_subscription, -> { where(available_for_subscription: true) }
  scope :active, -> { joins(:product_status).where(product_statuses: { is_available: true }) }
  scope :heterologous_expression, -> { where(category: "Heterologous Protein Expression") }
  scope :genome_engineering, -> { where(category: "Genome Engineering") }

  # Scopes to match ExpressionVector behavior
  scope :available, -> { available_for_sale.active }
  scope :protein_expression, -> { heterologous_expression }

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

  # Check if map image blob actually exists
  def map_image_exists?
    return false unless map_image.attached?

    map_image.blob.service.exist?(map_image.blob.key)
  rescue => e
    Rails.logger.error "Error checking map image existence for vector #{id}: #{e.message}"
    false
  end

  # Generate thumbnail variant for vector map
  def map_thumbnail
    return nil unless map_image.attached?

    # Skip variants in production to save memory - just use original
    if Rails.env.production?
      # Check if the file actually exists before returning it
      return map_image_exists? ? map_image : nil
    end

    # Return original if it's already small enough or if variants aren't supported
    return map_image unless map_image.variable?

    map_image.variant(
      resize_to_fill: [ 612, 452 ],
      format: :webp,
      saver: { quality: 85 }
    ).processed
  rescue => e
    Rails.logger.error "Error generating thumbnail for vector #{id}: #{e.message}"
    # In production, check if original exists before returning it
    Rails.env.production? && !map_image_exists? ? nil : map_image
  end

  # Generate large variant for vector map modal
  def map_large
    return nil unless map_image.attached?

    # Skip variants in production to save memory - just use original
    if Rails.env.production?
      # Check if the file actually exists before returning it
      return map_image_exists? ? map_image : nil
    end

    # Return original if variants aren't supported
    return map_image unless map_image.variable?

    map_image.variant(
      resize_to_limit: [ 3087, 1620 ],
      format: :webp,
      saver: { quality: 90 }
    ).processed
  rescue => e
    Rails.logger.error "Error generating large variant for vector #{id}: #{e.message}"
    # In production, check if original exists before returning it
    Rails.env.production? && !map_image_exists? ? nil : map_image
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

  # Methods to match ExpressionVector interface
  def display_name
    if promoter && selection_marker
      "#{name} (#{promoter.name}/#{selection_marker.name})"
    else
      name
    end
  end

  def feature_list
    return [] if features.blank?
    features.split(",").map(&:strip)
  end

  def formatted_price
    if available_for_sale? && sale_price
      "$#{sale_price.to_f}"
    else
      "Contact for pricing"
    end
  end

  # Additional getter methods for compatibility
  def backbone
    # This field doesn't exist in vectors table, could be added or derived from description
    nil
  end

  def cloning_sites
    # This field doesn't exist in vectors table, could be added or derived from features
    feature_list.select { |f| f.downcase.include?("site") || f.downcase.include?("cloning") }.join(", ")
  end

  def additional_notes
    # Map to description field
    description
  end

  def drug_selection
    selection_marker&.name || "Not specified"
  end

  def price
    sale_price
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
