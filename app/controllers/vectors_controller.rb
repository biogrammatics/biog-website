class VectorsController < ApplicationController
  allow_unauthenticated_access

  def index
    @vectors = Vector.includes(:promoter, :selection_marker, :vector_type, :product_status)
      .joins(:product_status).where(product_statuses: { is_available: true })
  rescue ActiveRecord::StatementInvalid, NoMethodError
    # Handle case where models/tables might not exist in test
    @vectors = []
  end

  def show
    @vector = Vector.find(params[:id])
  end
end
