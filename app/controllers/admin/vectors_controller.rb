class Admin::VectorsController < Admin::BaseController
  before_action :set_vector, only: [ :show, :edit, :update, :destroy, :remove_file, :remove_map ]
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
    # Extract files from params to handle them separately
    files_to_attach = params.dig(:vector, :files)

    # Create a copy of vector_params and remove files from it
    update_params = vector_params
    update_params.delete(:files) if update_params[:files]

    if @vector.update(update_params)
      # Attach new files if any were uploaded
      if files_to_attach.present? && files_to_attach.reject(&:blank?).any?
        begin
          @vector.files.attach(files_to_attach.reject(&:blank?))
          Rails.logger.info "Attached #{files_to_attach.reject(&:blank?).count} files to vector #{@vector.id}"
        rescue => e
          Rails.logger.error "Failed to attach files to vector #{@vector.id}: #{e.message}"
        end
      end

      redirect_to admin_vector_path(@vector), notice: "Vector was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @vector.can_be_deleted?
      @vector.destroy
      redirect_to admin_vectors_path, notice: "Vector was successfully deleted."
    else
      redirect_to admin_vector_path(@vector), alert: "Cannot delete this vector: #{@vector.errors.full_messages.join(', ')}"
    end
  end

  def remove_file
    file = @vector.files.find(params[:file_id])
    file.purge
    redirect_to edit_admin_vector_path(@vector), notice: "File was successfully removed."
  end

  def remove_map
    @vector.map_image.purge if @vector.map_image.attached?
    redirect_to edit_admin_vector_path(@vector), notice: "Vector map was successfully removed."
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
    permitted_params = params.require(:vector).permit(:name, :description, :category, :available_for_sale,
                                                      :available_for_subscription, :sale_price, :subscription_price,
                                                      :promoter_id, :selection_marker_id, :vector_type_id,
                                                      :host_organism_id, :has_lox_sites, :vector_size,
                                                      :file_version, :features, :product_status_id, :has_files,
                                                      :map_image, files: [])

    # Convert blank category to nil to avoid constraint violations
    permitted_params[:category] = nil if permitted_params[:category].blank?

    permitted_params
  end
end
