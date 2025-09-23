class Admin::SelectionMarkersController < Admin::BaseController
  before_action :set_selection_marker, only: [ :show, :edit, :update, :destroy ]

  def index
    @selection_markers = SelectionMarker.all.order(:name)
  end

  def show
  end

  def new
    @selection_marker = SelectionMarker.new
  end

  def create
    @selection_marker = SelectionMarker.new(selection_marker_params)

    if @selection_marker.save
      redirect_to admin_selection_markers_path, notice: "Selection marker was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @selection_marker.update(selection_marker_params)
      redirect_to admin_selection_markers_path, notice: "Selection marker was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @selection_marker.vectors.any?
      redirect_to admin_selection_markers_path, alert: "Cannot delete selection marker that is being used by vectors."
    else
      @selection_marker.destroy
      redirect_to admin_selection_markers_path, notice: "Selection marker was successfully deleted."
    end
  end

  private

  def set_selection_marker
    @selection_marker = SelectionMarker.find(params[:id])
  end

  def selection_marker_params
    params.require(:selection_marker).permit(:name, :resistance, :concentration)
  end
end
