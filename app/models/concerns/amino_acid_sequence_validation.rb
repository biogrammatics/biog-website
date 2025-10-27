module AminoAcidSequenceValidation
  extend ActiveSupport::Concern

  included do
    # Valid amino acids for sequence validation
    AMINO_ACIDS = %w[A R N D C E Q G H I L K M F P S T W Y V *].freeze
  end

  # Clean and normalize amino acid sequence
  def clean_amino_acid_sequence
    return nil unless amino_acid_sequence.present?
    amino_acid_sequence.gsub(/\s+/, "").upcase
  end

  # Get the length of the cleaned sequence
  def sequence_length
    return 0 unless amino_acid_sequence.present?
    clean_amino_acid_sequence.length
  end

  # Check if sequence starts with methionine
  def starts_with_methionine?
    return false unless amino_acid_sequence.present?
    clean_amino_acid_sequence.start_with?("M")
  end

  # Check if sequence ends with stop codon
  def ends_with_stop_codon?
    return false unless amino_acid_sequence.present?
    clean_amino_acid_sequence.end_with?("*")
  end

  # Estimate molecular weight (average amino acid ~ 110 Da)
  def estimated_molecular_weight
    return nil unless sequence_length > 0
    (sequence_length * 110).round
  end

  private

  # Validate amino acid sequence composition and format
  # Options:
  #   require_methionine: true/false (default: false)
  #   require_stop_codon: true/false (default: false)
  #   minimum_length: integer (default: 2)
  def validate_amino_acid_sequence_format(options = {})
    return unless amino_acid_sequence.present?

    cleaned_sequence = clean_amino_acid_sequence

    # Set default options
    require_methionine = options.fetch(:require_methionine, false)
    require_stop_codon = options.fetch(:require_stop_codon, false)
    minimum_length = options.fetch(:minimum_length, 2)

    # Check if sequence contains only valid amino acids
    invalid_chars = cleaned_sequence.chars.uniq - AMINO_ACIDS
    if invalid_chars.any?
      errors.add(:amino_acid_sequence, "contains invalid amino acid codes: #{invalid_chars.join(', ')}")
    end

    # Check if sequence starts with methionine (if required)
    if require_methionine && !cleaned_sequence.start_with?("M")
      errors.add(:amino_acid_sequence, "must start with methionine (M)")
    end

    # Check if sequence ends with stop codon (if required)
    if require_stop_codon && !cleaned_sequence.end_with?("*")
      errors.add(:amino_acid_sequence, "must end with stop codon (*)")
    end

    # Check minimum length
    if cleaned_sequence.length < minimum_length
      if require_methionine && require_stop_codon
        errors.add(:amino_acid_sequence, "must be at least #{minimum_length} amino acids long (M....*)")
      else
        errors.add(:amino_acid_sequence, "must be at least #{minimum_length} amino acids long")
      end
    end
  end
end
