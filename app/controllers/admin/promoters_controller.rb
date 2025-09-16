class Admin::PromotersController < ApplicationController
  before_action :require_authentication
  before_action :require_admin
  before_action :set_promoter, only: [ :show, :edit, :update, :destroy ]

  def index
    @promoters = Promoter.all.order(:name)
  end

  def show
  end

  def new
    @promoter = Promoter.new
  end

  def create
    @promoter = Promoter.new(promoter_params)

    if @promoter.save
      redirect_to admin_promoters_path, notice: "Promoter was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @promoter.update(promoter_params)
      redirect_to admin_promoters_path, notice: "Promoter was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @promoter.vectors.any?
      redirect_to admin_promoters_path, alert: "Cannot delete promoter that is being used by vectors."
    else
      @promoter.destroy
      redirect_to admin_promoters_path, notice: "Promoter was successfully deleted."
    end
  end

  private

  def set_promoter
    @promoter = Promoter.find(params[:id])
  end

  def promoter_params
    params.require(:promoter).permit(:name, :full_name, :inducible, :strength)
  end

  def require_admin
    redirect_to root_path, alert: "Not authorized" unless admin_signed_in?
  end
end
