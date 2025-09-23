class CustomProjectsController < ApplicationController
  allow_unauthenticated_access only: [ :new, :services, :protein_expression, :enhanced_protein_expression ]
  before_action :require_authentication, except: [ :new, :services, :protein_expression, :enhanced_protein_expression ]
  before_action :set_custom_project, only: [ :show, :edit, :update, :destroy, :approve_dna_sequence, :reject_dna_sequence ]

  def index
    @custom_projects = Current.user.custom_projects.order(created_at: :desc)
  end

  def show
  end

  def new
    @form = CustomProjectForm.new(authenticated? ? Current.user : nil)
  end

  def services
  end

  # New action for protein expression strain requests
  def protein_expression
    if request.post?
      # Handle form submission - require authentication
      unless authenticated?
        redirect_to new_session_path, alert: "Please sign in to submit a protein expression request."
        return
      end

      @form = ProteinExpressionForm.new(Current.user, protein_expression_params)

      if @custom_project = @form.save
        redirect_to @custom_project, notice: "Protein expression strain request submitted successfully! We'll generate the DNA sequence and contact you for approval."
      else
        @expression_vectors = Vector.available.protein_expression
        render :protein_expression, status: :unprocessable_entity
      end
    else
      # Show form
      @form = ProteinExpressionForm.new(authenticated? ? Current.user : nil)
      @expression_vectors = Vector.available.protein_expression
    end
  end

  # Enhanced protein expression with FASTA upload and multiple proteins
  def enhanced_protein_expression
    if request.post?
      # Handle form submission - require authentication
      unless authenticated?
        redirect_to new_session_path, alert: "Please sign in to submit an enhanced protein expression request."
        return
      end

      @form = EnhancedProteinExpressionForm.new(Current.user, enhanced_protein_expression_params)

      if @custom_project = @form.save
        protein_count = @custom_project.proteins.count
        redirect_to @custom_project, notice: "Enhanced protein expression request submitted successfully! #{protein_count} protein(s) will be processed and optimized."
      else
        @expression_vectors = Vector.available.protein_expression
        render :enhanced_protein_expression, status: :unprocessable_entity
      end
    else
      # Show form
      @form = EnhancedProteinExpressionForm.new(authenticated? ? Current.user : nil)
      @expression_vectors = Vector.available.protein_expression
    end
  end

  def create
    @form = CustomProjectForm.new(Current.user, custom_project_params)

    if @custom_project = @form.save
      redirect_to @custom_project, notice: "Custom project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @custom_project.update(custom_project_params)
      redirect_to @custom_project, notice: "Custom project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Rails.logger.info "Attempting to destroy custom project #{@custom_project.id}"

    if @custom_project.destroy
      Rails.logger.info "Successfully destroyed custom project #{@custom_project.id}"
      redirect_to custom_projects_url, notice: "Custom project was successfully deleted."
    else
      Rails.logger.error "Failed to destroy custom project #{@custom_project.id}: #{@custom_project.errors.full_messages.join(', ')}"
      redirect_to @custom_project, alert: "Could not delete project: #{@custom_project.errors.full_messages.join(', ')}"
    end
  end

  def approve_dna_sequence
    @custom_project.update!(
      dna_sequence_approved: true,
      status: "sequence_approved"
    )
    redirect_to @custom_project, notice: "DNA sequence approved! Your strain will now be synthesized and cloned."
  end

  def reject_dna_sequence
    @custom_project.update!(
      dna_sequence_approved: false,
      status: "pending",
      dna_sequence: nil
    )
    redirect_to @custom_project, notice: "DNA sequence rejected. We'll generate a new sequence for your review."
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

  def protein_expression_params
    params.require(:custom_project).permit(
      :project_name, :protein_name, :protein_description,
      :amino_acid_sequence, :selected_vector_id, :notes
    )
  end

  def enhanced_protein_expression_params
    params.require(:enhanced_protein_expression_form).permit(
      :project_name, :selected_vector_id, :notes, :input_method, :fasta_file,
      proteins_attributes: [
        :name, :description, :amino_acid_sequence,
        :secretion_signal, :n_terminal_tag, :c_terminal_tag
      ]
    )
  end
end
