class CustomProject < ApplicationRecord
  belongs_to :user
  belongs_to :selected_vector, class_name: "Vector", foreign_key: :selected_vector_id, optional: true

  STATUSES = %w[pending in_progress completed cancelled awaiting_approval sequence_approved].freeze
  PROJECT_TYPES = %w[strain_only strain_and_testing full_service consultation protein_expression].freeze

  # Valid amino acids for sequence validation
  AMINO_ACIDS = %w[A R N D C E Q G H I L K M F P S T W Y V *].freeze

  validates :project_name, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :project_type, inclusion: { in: PROJECT_TYPES }, allow_nil: true

  # Set default status
  after_initialize :set_default_status, if: :new_record?

  # Protein expression specific validations
  validates :protein_name, presence: true, if: :protein_expression_project?
  validates :amino_acid_sequence, presence: true, if: :protein_expression_project?
  validates :selected_vector_id, presence: true, if: :protein_expression_project?
  validate :validate_amino_acid_sequence, if: :protein_expression_project?

  scope :pending, -> { where(status: "pending") }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }
  scope :awaiting_approval, -> { where(status: "awaiting_approval") }
  scope :sequence_approved, -> { where(status: "sequence_approved") }
  scope :protein_expression, -> { where(project_type: "protein_expression") }

  def total_services
    services = []
    services << "Custom Strain Generation" if strain_generation?
    services << "Expression Testing" if expression_testing?
    services << "Protein Expression" if protein_expression_project?
    services
  end

  def display_status
    case status
    when "awaiting_approval"
      "Awaiting DNA Sequence Approval"
    when "sequence_approved"
      "DNA Sequence Approved"
    else
      status.humanize
    end
  end

  def protein_expression_project?
    project_type == "protein_expression"
  end

  def clean_amino_acid_sequence
    return nil unless amino_acid_sequence.present?
    # Remove whitespace, newlines, and convert to uppercase
    amino_acid_sequence.gsub(/\s+/, "").upcase
  end

  def sequence_length
    return 0 unless amino_acid_sequence.present?
    clean_amino_acid_sequence.length
  end

  def starts_with_methionine?
    return false unless amino_acid_sequence.present?
    clean_amino_acid_sequence.start_with?("M")
  end

  def ends_with_stop_codon?
    return false unless amino_acid_sequence.present?
    clean_amino_acid_sequence.end_with?("*")
  end

  def estimated_molecular_weight
    # Simple molecular weight estimation (average amino acid ~ 110 Da)
    return nil unless sequence_length > 0
    (sequence_length * 110).round
  end

  private

  def validate_amino_acid_sequence
    return unless amino_acid_sequence.present?

    cleaned_sequence = clean_amino_acid_sequence

    # Check if sequence contains only valid amino acids
    invalid_chars = cleaned_sequence.chars.uniq - AMINO_ACIDS
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

    # Check minimum length (methionine + at least one other amino acid + stop codon)
    if cleaned_sequence.length < 3
      errors.add(:amino_acid_sequence, "must be at least 3 amino acids long (M....*)")
    end
  end

  def set_default_status
    self.status ||= "pending"
  end
end
