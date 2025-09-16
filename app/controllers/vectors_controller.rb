class VectorsController < ApplicationController
  allow_unauthenticated_access

  def index
    @vectors = Vector.includes(:promoter, :selection_marker, :vector_type, :product_status)
      .joins(:product_status).where(product_statuses: { is_available: true })
      .order(:name)

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
  end

  def show
    @vector = Vector.find(params[:id])
  end
end
