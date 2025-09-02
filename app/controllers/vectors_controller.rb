class VectorsController < ApplicationController
  def index
    @vectors = Vector.active.includes(:promoter, :selection_marker, :vector_type, :product_status)
  end

  def show
    @vector = Vector.find(params[:id])
  end
end
