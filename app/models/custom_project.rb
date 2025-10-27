class CustomProject < ApplicationRecord
  include AminoAcidSequenceValidation

  belongs_to :user
  belongs_to :selected_vector, class_name: "Vector", foreign_key: :selected_vector_id, optional: true
  has_many :proteins, dependent: :destroy
  has_one_attached :fasta_file

  STATUSES = %w[pending in_progress completed cancelled awaiting_approval sequence_approved].freeze
  PROJECT_TYPES = %w[strain_only strain_and_testing full_service consultation protein_expression].freeze

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

  private

  def validate_amino_acid_sequence
    validate_amino_acid_sequence_format(
      require_methionine: true,
      require_stop_codon: true,
      minimum_length: 3
    )
  end

  def set_default_status
    self.status ||= "pending"
  end
end
