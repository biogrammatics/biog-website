class CustomProjectsController < ApplicationController
  allow_unauthenticated_access only: [ :new, :protein_expression ]
  before_action :require_authentication, except: [ :new, :protein_expression ]
  before_action :set_custom_project, only: [ :show, :edit, :update, :destroy, :approve_dna_sequence, :reject_dna_sequence ]

  def index
    @custom_projects = Current.user.custom_projects.order(created_at: :desc)
  end

  def show
  end

  def new
    @custom_project = authenticated? ? Current.user.custom_projects.build : CustomProject.new
  end

  # New action for protein expression strain requests
  def protein_expression
    if request.post?
      # Handle form submission - require authentication
      unless authenticated?
        redirect_to new_session_path, alert: "Please sign in to submit a protein expression request."
        return
      end

      @custom_project = Current.user.custom_projects.build(protein_expression_params)
      @custom_project.project_type = "protein_expression"

      if @custom_project.save
        # Generate DNA sequence (simulated for now)
        generate_dna_sequence(@custom_project)
        redirect_to @custom_project, notice: "Protein expression strain request submitted successfully! We'll generate the DNA sequence and contact you for approval."
      else
        @expression_vectors = ExpressionVector.available.protein_expression
        render :protein_expression, status: :unprocessable_entity
      end
    else
      # Show form
      @custom_project = authenticated? ? Current.user.custom_projects.build : CustomProject.new
      @expression_vectors = ExpressionVector.available.protein_expression
    end
  end

  def create
    @custom_project = Current.user.custom_projects.build(custom_project_params)

    if @custom_project.save
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
    @custom_project.destroy
    redirect_to custom_projects_url, notice: "Custom project was successfully deleted."
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

  # Simulate DNA sequence generation (in production, this would use actual codon optimization)
  def generate_dna_sequence(project)
    return unless project.amino_acid_sequence.present?

    # Simple codon table for demonstration (E. coli optimized)
    codon_table = {
      "M" => "ATG", "A" => "GCA", "R" => "CGC", "N" => "AAC", "D" => "GAC",
      "C" => "TGC", "E" => "GAA", "Q" => "CAG", "G" => "GGC", "H" => "CAC",
      "I" => "ATC", "L" => "CTG", "K" => "AAG", "F" => "TTC", "P" => "CCC",
      "S" => "TCC", "T" => "ACC", "W" => "TGG", "Y" => "TAC", "V" => "GTC",
      "*" => "TAA"
    }

    cleaned_sequence = project.clean_amino_acid_sequence
    dna_sequence = cleaned_sequence.chars.map { |aa| codon_table[aa] || "NNN" }.join

    project.update!(
      dna_sequence: dna_sequence,
      status: "awaiting_approval",
      codon_optimization_notes: "Generated using BioGrammatics proprietary Pichia pastoris codon optimization protocol. Sequence optimized for high expression in Pichia."
    )
  end
end
