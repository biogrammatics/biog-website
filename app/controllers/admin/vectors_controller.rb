class Admin::VectorsController < ApplicationController
  before_action :require_admin!
  before_action :set_vector, only: [ :show, :edit, :update, :destroy ]
  before_action :load_form_data, only: [ :new, :edit, :create, :update ]

  def index
    @vectors = Vector.includes(:promoter, :selection_marker, :vector_type, :host_organism, :product_status)
                    .order(:name)
  end

  def show
  end

  def new
    @vector = Vector.new
  end

  def create
    @vector = Vector.new(vector_params)

    if @vector.save
      redirect_to admin_vector_path(@vector), notice: "Vector was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vector.update(vector_params)
      redirect_to admin_vector_path(@vector), notice: "Vector was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vector.destroy
    redirect_to admin_vectors_path, notice: "Vector was successfully deleted."
  end

  private

  def set_vector
    @vector = Vector.find(params[:id])
  end

  def load_form_data
    @promoters = Promoter.order(:name)
    @selection_markers = SelectionMarker.order(:name)
    @vector_types = VectorType.order(:name)
    @host_organisms = HostOrganism.order(:common_name)
    @product_statuses = ProductStatus.order(:name)
  end

  def vector_params
    params.require(:vector).permit(:name, :description, :category, :available_for_sale,
                                   :available_for_subscription, :sale_price, :subscription_price,
                                   :promoter_id, :selection_marker_id, :vector_type_id,
                                   :host_organism_id, :has_lox_sites, :vector_size,
                                   :file_version, :features, :product_status_id, :has_files)
  end
end
