class Protein < ApplicationRecord
  include AminoAcidSequenceValidation

  belongs_to :custom_project

  validates :name, presence: true
  validates :amino_acid_sequence, presence: true
  validates :sequence_order, presence: true, uniqueness: { scope: :custom_project_id }
  validate :validate_amino_acid_sequence

  scope :ordered, -> { order(:sequence_order) }

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
    validate_amino_acid_sequence_format(minimum_length: 2)
  end
end
