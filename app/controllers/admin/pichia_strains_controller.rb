class Admin::PichiaStrainsController < ApplicationController
  before_action :require_admin!
  before_action :set_pichia_strain, only: [:show, :edit, :update, :destroy]
  before_action :load_form_data, only: [:new, :edit, :create, :update]

  def index
    @pichia_strains = PichiaStrain.includes(:strain_type, :product_status).order(:name)
  end

  def show
  end

  def new
    @pichia_strain = PichiaStrain.new
  end

  def create
    @pichia_strain = PichiaStrain.new(pichia_strain_params)
    
    if @pichia_strain.save
      redirect_to admin_pichia_strain_path(@pichia_strain), notice: 'Pichia strain was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @pichia_strain.update(pichia_strain_params)
      redirect_to admin_pichia_strain_path(@pichia_strain), notice: 'Pichia strain was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pichia_strain.destroy
    redirect_to admin_pichia_strains_path, notice: 'Pichia strain was successfully deleted.'
  end

  private

  def set_pichia_strain
    @pichia_strain = PichiaStrain.find(params[:id])
  end

  def load_form_data
    @strain_types = StrainType.order(:name)
    @product_statuses = ProductStatus.order(:name)
  end

  def pichia_strain_params
    params.require(:pichia_strain).permit(:name, :description, :strain_type_id, :genotype, 
                                          :phenotype, :advantages, :applications, :sale_price,
                                          :availability, :shipping_requirements, :storage_conditions,
                                          :viability_period, :culture_media, :growth_conditions,
                                          :citations, :has_files, :file_notes, :product_status_id)
  end
end
