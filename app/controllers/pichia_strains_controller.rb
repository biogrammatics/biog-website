class PichiaStrainsController < ApplicationController
  allow_unauthenticated_access
  
  def index
    @pichia_strains = PichiaStrain.active.includes(:strain_type, :product_status)
  end

  def show
    @pichia_strain = PichiaStrain.find(params[:id])
  end
end
