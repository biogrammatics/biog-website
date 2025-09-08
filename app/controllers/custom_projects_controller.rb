class CustomProjectsController < ApplicationController
  allow_unauthenticated_access only: [:new]
  before_action :require_authentication, except: [:new]
  before_action :set_custom_project, only: [:show, :edit, :update, :destroy]
  
  def index
    @custom_projects = Current.user.custom_projects.order(created_at: :desc)
  end

  def show
  end

  def new
    @custom_project = authenticated? ? Current.user.custom_projects.build : CustomProject.new
  end
  
  def create
    @custom_project = Current.user.custom_projects.build(custom_project_params)
    
    if @custom_project.save
      redirect_to @custom_project, notice: 'Custom project was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @custom_project.update(custom_project_params)
      redirect_to @custom_project, notice: 'Custom project was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @custom_project.destroy
    redirect_to custom_projects_url, notice: 'Custom project was successfully deleted.'
  end
  
  private
  
  def set_custom_project
    @custom_project = Current.user.custom_projects.find(params[:id])
  end
  
  def custom_project_params
    params.require(:custom_project).permit(
      :project_name, :project_type, :description, 
      :strain_generation, :expression_testing, :notes
    )
  end
end
