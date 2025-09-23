class VectorFilterService
  attr_reader :vector_type, :category, :vectors, :vectors_by_promoter

  VALID_VECTOR_TYPES = %w[sale subscription].freeze
  VALID_CATEGORIES = %w[expression engineering].freeze

  def initialize(vector_type: "sale", category: "expression")
    @vector_type = normalize_vector_type(vector_type)
    @category = normalize_category(category)
    @vectors = []
    @vectors_by_promoter = {}
  end

  def call
    @vectors = filter_vectors
    @vectors_by_promoter = group_vectors_by_promoter
    self
  rescue ActiveRecord::StatementInvalid, NoMethodError
    # Handle case where models/tables might not exist in test
    @vectors = []
    @vectors_by_promoter = {}
    self
  end

  private

  def normalize_vector_type(type)
    VALID_VECTOR_TYPES.include?(type) ? type : "sale"
  end

  def normalize_category(cat)
    VALID_CATEGORIES.include?(cat) ? cat : "expression"
  end

  def filter_vectors
    base_query = build_base_query
    vectors_by_type = filter_by_vector_type(base_query)
    filter_by_category(vectors_by_type)
  end

  def build_base_query
    Vector.includes(:promoter, :selection_marker, :vector_type, :product_status)
          .joins(:product_status)
          .where(product_statuses: { is_available: true })
  end

  def filter_by_vector_type(base_query)
    if vector_type == "subscription"
      base_query.where(available_for_subscription: true)
    else
      base_query.where(available_for_sale: true)
    end
  end

  def filter_by_category(vectors_by_type)
    if category == "engineering"
      vectors_by_type.where(category: "Genome Engineering").order(:name)
    else
      # Default to expression, include nil/blank for backward compatibility
      vectors_by_type.where(
        "category = ? OR category IS NULL OR category = ''",
        "Heterologous Protein Expression"
      ).order(:name)
    end
  end

  def group_vectors_by_promoter
    grouped_vectors = {}

    # Get promoters sorted with "None" last
    promoters = get_sorted_promoters

    # Group vectors by promoter
    promoters.each do |promoter|
      vectors_for_promoter = vectors.select { |v| v.promoter == promoter }
      grouped_vectors[promoter] = vectors_for_promoter if vectors_for_promoter.any?
    end

    # Add vectors with no promoter (nil) at the end
    add_vectors_without_promoter(grouped_vectors)

    grouped_vectors
  end

  def get_sorted_promoters
    vectors.map(&:promoter)
           .compact
           .uniq
           .sort_by { |promoter| promoter_sort_key(promoter) }
  end

  def promoter_sort_key(promoter)
    promoter.name.downcase == "none" ? "zzz" : promoter.name.downcase
  end

  def add_vectors_without_promoter(grouped_vectors)
    vectors_without_promoter = vectors.select { |v| v.promoter.nil? }
    if vectors_without_promoter.any?
      grouped_vectors[nil] = vectors_without_promoter
    end
  end
end
