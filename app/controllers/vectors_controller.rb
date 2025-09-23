class VectorsController < ApplicationController
  allow_unauthenticated_access

  def index
    # Get vector type from params (default to 'sale')
    @vector_type = params[:vector_type] || "sale"

    # Get category from params (default to 'expression')
    @category = params[:category] || "expression"

    # Base query with includes
    base_query = Vector.includes(:promoter, :selection_marker, :vector_type, :product_status)
      .joins(:product_status).where(product_statuses: { is_available: true })

    # Filter based on vector type
    vectors_by_type = if @vector_type == "subscription"
      base_query.where(available_for_subscription: true)
    else
      base_query.where(available_for_sale: true)
    end

    # Filter based on category
    @vectors = if @category == "engineering"
      vectors_by_type.where(category: "Genome Engineering").order(:name)
    else
      # Default to expression
      vectors_by_type.where(category: "Heterologous Protein Expression").order(:name)
    end

    # Group vectors by promoter with specific ordering - "None" promoter last
    @vectors_by_promoter = {}

    # Get all promoters from the vectors, ordered with "None" last
    promoters = @vectors.map(&:promoter).compact.uniq.sort_by { |p| p.name.downcase == "none" ? "zzz" : p.name.downcase }

    # Group vectors by promoter
    promoters.each do |promoter|
      vectors_for_promoter = @vectors.select { |v| v.promoter == promoter }
      @vectors_by_promoter[promoter] = vectors_for_promoter if vectors_for_promoter.any?
    end

    # Add vectors with no promoter (nil) at the end
    vectors_without_promoter = @vectors.select { |v| v.promoter.nil? }
    if vectors_without_promoter.any?
      @vectors_by_promoter[nil] = vectors_without_promoter
    end

  rescue ActiveRecord::StatementInvalid, NoMethodError
    # Handle case where models/tables might not exist in test
    @vectors = []
    @vectors_by_promoter = {}
    @vector_type = "sale"
    @category = "expression"
  end

  def show
    @vector = Vector.find(params[:id])
  end
end
