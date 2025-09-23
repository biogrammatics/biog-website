class Vector < ApplicationRecord
  include VectorFileManager
  include VectorPricing

  CATEGORIES = [
    "Heterologous Protein Expression",
    "Genome Engineering"
  ].freeze

  belongs_to :promoter, optional: true
  belongs_to :selection_marker, optional: true
  belongs_to :vector_type, optional: true
  belongs_to :host_organism, optional: true
  belongs_to :product_status
  has_many :subscription_vectors, dependent: :destroy
  has_many :subscriptions, through: :subscription_vectors
  has_many :custom_projects, foreign_key: :selected_vector_id, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true

  before_validation :set_default_category
  before_destroy :check_if_can_be_deleted

  scope :active, -> { joins(:product_status).where(product_statuses: { is_available: true }) }
  scope :heterologous_expression, -> { where(category: "Heterologous Protein Expression") }
  scope :genome_engineering, -> { where(category: "Genome Engineering") }

  # Scopes to match ExpressionVector behavior
  scope :available, -> { available_for_sale.active }
  scope :protein_expression, -> { heterologous_expression }


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

  private

  def set_default_category
    # Normalize blank strings to nil, then set default category
    self.category = nil if category.blank?

    if category.nil?
      self.category = "Heterologous Protein Expression"
    end
  end
end
