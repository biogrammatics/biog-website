class Admin::CustomProjectsController < ApplicationController
  before_action :require_admin!
  before_action :set_custom_project, only: [ :show, :edit, :update, :update_status, :destroy ]

  def index
    @custom_projects = CustomProject.includes(:user).order(created_at: :desc)
    @pending_projects = @custom_projects.pending
    @in_progress_projects = @custom_projects.in_progress
    @completed_projects = @custom_projects.completed
  end

  def show
  end

  def edit
  end

  def update
    if @custom_project.update(admin_custom_project_params)
      redirect_to admin_custom_project_path(@custom_project), notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_status
    if @custom_project.update(status: params[:status])
      redirect_to admin_custom_projects_path, notice: "Project status updated to #{@custom_project.display_status}."
    else
      redirect_to admin_custom_projects_path, alert: "Failed to update project status."
    end
  end

  def destroy
    @custom_project.destroy
    redirect_to admin_custom_projects_url, notice: "Custom project was successfully deleted."
  end

  private

  def set_custom_project
    @custom_project = CustomProject.find(params[:id])
  end

  def admin_custom_project_params
    params.require(:custom_project).permit(
      :project_name, :project_type, :description,
      :strain_generation, :expression_testing, :notes,
      :status, :estimated_cost, :estimated_completion_date
    )
  end
end
