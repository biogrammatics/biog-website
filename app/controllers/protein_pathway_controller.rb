class ProteinPathwayController < ApplicationController
  allow_unauthenticated_access
  before_action :load_service_packages, only: [ :index, :step, :review ]
  before_action :set_current_step, only: [ :step ]

  # Landing page - "Your Path to Protein"
  def index
    @total_value = ServicePackage.active.sum(:estimated_price)
  end

  # Individual step page
  def step
    @service_package = ServicePackage.find_by!(step_number: @current_step)
    @previous_selections = current_pathway_selections
  end

  # Handle step selection (DIY or Service)
  def select
    step_number = params[:step_number].to_i
    selection_type = params[:selection_type] # "diy" or "service"
    service_package = ServicePackage.find_by!(step_number: step_number)

    selection = PathwaySelection.find_or_initialize_by(
      session_id: pathway_session_id,
      user_id: authenticated? ? Current.user.id : nil,
      step_number: step_number
    )

    selection.update!(
      selection_type: selection_type,
      service_package_id: service_package.id,
      notes: params[:notes]
    )

    # Move to next step or review
    if step_number < 6
      redirect_to protein_pathway_step_path(step: step_number + 1)
    else
      redirect_to protein_pathway_review_path
    end
  end

  # Review all selections before requesting quote
  def review
    @selections = current_pathway_selections
    @service_selections = @selections.select(&:service?)
    @total_estimate = @service_selections.sum { |s| s.service_package.estimated_price }
  end

  # Quote request form
  def quote_form
    @selections = current_pathway_selections
    @service_quote = ServiceQuote.new
  end

  # Submit quote request
  def submit_quote
    @service_quote = ServiceQuote.new(quote_params)
    @service_quote.session_id = pathway_session_id
    @service_quote.user_id = Current.user.id if authenticated?
    @service_quote.selected_services = build_selected_services
    @service_quote.estimated_total = calculate_total_estimate

    if @service_quote.save
      # TODO: Send confirmation email
      # TODO: Notify admin of new quote request
      redirect_to protein_pathway_thank_you_path, notice: "Thank you! We'll send you a detailed quote within 24 hours."
    else
      render :quote_form, status: :unprocessable_entity
    end
  end

  # Thank you page after quote submission
  def thank_you
    # Clear the pathway session after successful submission
    session.delete(:pathway_session_id)
  end

  private

  def load_service_packages
    @service_packages = ServicePackage.active.by_step
  end

  def set_current_step
    @current_step = params[:step].to_i
    redirect_to protein_pathway_path if @current_step < 1 || @current_step > 6
  end

  def pathway_session_id
    session[:pathway_session_id] ||= SecureRandom.uuid
  end

  def current_pathway_selections
    PathwaySelection
      .where(session_id: pathway_session_id)
      .includes(:service_package)
      .order(:step_number)
  end

  def build_selected_services
    current_pathway_selections.select(&:service?).map do |selection|
      {
        step_number: selection.step_number,
        service_package_id: selection.service_package_id,
        name: selection.service_package.name,
        price: selection.service_package.estimated_price.to_f
      }
    end
  end

  def calculate_total_estimate
    current_pathway_selections.select(&:service?).sum do |selection|
      selection.service_package.estimated_price
    end
  end

  def quote_params
    params.require(:service_quote).permit(
      :email_address,
      :full_name,
      :organization,
      :phone_number,
      :project_name,
      :target_protein_name,
      :protein_tags,
      :special_requirements,
      :notes
    )
  end
end
