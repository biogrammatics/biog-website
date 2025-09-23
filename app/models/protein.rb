class Protein < ApplicationRecord
  belongs_to :custom_project

  # Valid amino acids for sequence validation
  AMINO_ACIDS = %w[A R N D C E Q G H I L K M F P S T W Y V *].freeze

  validates :name, presence: true
  validates :amino_acid_sequence, presence: true
  validates :sequence_order, presence: true, uniqueness: { scope: :custom_project_id }
  validate :validate_amino_acid_sequence

  scope :ordered, -> { order(:sequence_order) }

  def clean_amino_acid_sequence
    return nil unless amino_acid_sequence.present?
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
    return nil unless sequence_length > 0
    (sequence_length * 110).round
  end

  def final_sequence_with_modifications
    sequence = clean_amino_acid_sequence
    return sequence unless sequence.present?

    # Remove the original methionine if adding secretion signal
    if secretion_signal.present?
      sequence = sequence[1..-1] if sequence.start_with?("M")
    end

    # Add secretion signal
    if secretion_signal.present?
      sequence = secretion_signal + sequence
    end

    # Add N-terminal tag (after secretion signal)
    if n_terminal_tag.present?
      # Insert after signal sequence or at beginning
      if secretion_signal.present?
        sequence = secretion_signal + n_terminal_tag + sequence[secretion_signal.length..-1]
      else
        sequence = n_terminal_tag + sequence
      end
    end

    # Add C-terminal tag (before stop codon)
    if c_terminal_tag.present?
      if sequence.end_with?("*")
        sequence = sequence[0..-2] + c_terminal_tag + "*"
      else
        sequence = sequence + c_terminal_tag
      end
    end

    sequence
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

    # Check minimum length
    if cleaned_sequence.length < 2
      errors.add(:amino_acid_sequence, "must be at least 2 amino acids long")
    end
  end
end
