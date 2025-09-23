class VectorsController < ApplicationController
  allow_unauthenticated_access

  def index
    filter_service = VectorFilterService.new(
      vector_type: params[:vector_type],
      category: params[:category]
    ).call

    @vector_type = filter_service.vector_type
    @category = filter_service.category
    @vectors = filter_service.vectors
    @vectors_by_promoter = filter_service.vectors_by_promoter
  end

  def show
    @vector = Vector.find(params[:id])
  end
end
