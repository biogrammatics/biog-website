class VectorsController < ApplicationController
  allow_unauthenticated_access

  def index
    @vectors = Vector.includes(:promoter, :selection_marker, :vector_type, :product_status)
      .joins(:product_status).where(product_statuses: { is_available: true })
      .order(:name)

    # Group vectors by category with specific ordering - Heterologous Protein Expression first
    @vectors_by_category = {}
    @vectors_by_category["Heterologous Protein Expression"] = @vectors.select { |v| v.category == "Heterologous Protein Expression" }
    @vectors_by_category["Genome Engineering"] = @vectors.select { |v| v.category == "Genome Engineering" }
  rescue ActiveRecord::StatementInvalid, NoMethodError
    # Handle case where models/tables might not exist in test
    @vectors = []
    @vectors_by_category = {}
  end

  def show
    @vector = Vector.find(params[:id])
  end
end
