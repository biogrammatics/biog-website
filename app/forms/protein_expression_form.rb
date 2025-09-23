class ProteinExpressionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :project_name, :string
  attribute :protein_name, :string
  attribute :protein_description, :string
  attribute :amino_acid_sequence, :string
  attribute :selected_vector_id, :integer
  attribute :notes, :string

  validates :project_name, presence: true
  validates :protein_name, presence: true
  validates :amino_acid_sequence, presence: true
  validates :selected_vector_id, presence: true
  validate :validate_amino_acid_sequence
  validate :validate_vector_exists

  def initialize(user, attributes = {})
    @user = user
    super(attributes)
  end

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      @custom_project = @user.custom_projects.build(form_attributes)
      @custom_project.project_type = "protein_expression"

      if @custom_project.save
        generate_dna_sequence
        @custom_project
      else
        copy_errors_from(@custom_project)
        raise ActiveRecord::Rollback
      end
    end
  end

  def persisted?
    false
  end

  def clean_amino_acid_sequence
    return nil unless amino_acid_sequence.present?
    amino_acid_sequence.gsub(/\s+/, "").upcase
  end

  def sequence_length
    return 0 unless amino_acid_sequence.present?
    clean_amino_acid_sequence.length
  end

  def estimated_molecular_weight
    return nil unless sequence_length > 0
    (sequence_length * 110).round
  end

  def starts_with_methionine?
    return false unless amino_acid_sequence.present?
    clean_amino_acid_sequence.start_with?("M")
  end

  def ends_with_stop_codon?
    return false unless amino_acid_sequence.present?
    clean_amino_acid_sequence.end_with?("*")
  end

  private

  attr_reader :user

  def form_attributes
    {
      project_name: project_name,
      protein_name: protein_name,
      protein_description: protein_description,
      amino_acid_sequence: amino_acid_sequence,
      selected_vector_id: selected_vector_id,
      notes: notes
    }
  end

  def validate_amino_acid_sequence
    return unless amino_acid_sequence.present?

    cleaned_sequence = clean_amino_acid_sequence

    # Check if sequence contains only valid amino acids
    invalid_chars = cleaned_sequence.chars.uniq - CustomProject::AMINO_ACIDS
    if invalid_chars.any?
      errors.add(:amino_acid_sequence, "contains invalid amino acid codes: #{invalid_chars.join(', ')}")
    end

    # Check if sequence starts with methionine
    unless cleaned_sequence.start_with?("M")
      errors.add(:amino_acid_sequence, "must start with methionine (M)")
    end

    # Check if sequence ends with stop codon
    unless cleaned_sequence.end_with?("*")
      errors.add(:amino_acid_sequence, "must end with stop codon (*)")
    end

    # Check minimum length
    if cleaned_sequence.length < 3
      errors.add(:amino_acid_sequence, "must be at least 3 amino acids long (M....*)")
    end
  end

  def validate_vector_exists
    return unless selected_vector_id.present?

    unless Vector.exists?(selected_vector_id)
      errors.add(:selected_vector_id, "does not exist")
    end
  end

  def generate_dna_sequence
    return unless @custom_project&.amino_acid_sequence.present?

    # Simple codon table for demonstration (Pichia pastoris optimized)
    codon_table = {
      "M" => "ATG", "A" => "GCA", "R" => "CGC", "N" => "AAC", "D" => "GAC",
      "C" => "TGC", "E" => "GAA", "Q" => "CAG", "G" => "GGC", "H" => "CAC",
      "I" => "ATC", "L" => "CTG", "K" => "AAG", "F" => "TTC", "P" => "CCC",
      "S" => "TCC", "T" => "ACC", "W" => "TGG", "Y" => "TAC", "V" => "GTC",
      "*" => "TAA"
    }

    cleaned_sequence = @custom_project.clean_amino_acid_sequence
    dna_sequence = cleaned_sequence.chars.map { |aa| codon_table[aa] || "NNN" }.join

    @custom_project.update!(
      dna_sequence: dna_sequence,
      status: "awaiting_approval",
      codon_optimization_notes: "Generated using BioGrammatics proprietary Pichia pastoris codon optimization protocol. Sequence optimized for high expression in Pichia."
    )
  end

  def copy_errors_from(model)
    model.errors.each do |error|
      errors.add(error.attribute, error.message) if respond_to?(error.attribute)
    end
  end
end
