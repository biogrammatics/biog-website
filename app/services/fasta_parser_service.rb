class FastaParserService
  attr_reader :errors, :proteins

  def initialize(file_content)
    @file_content = file_content
    @errors = []
    @proteins = []
  end

  def parse
    return false unless valid_content?

    sequences = extract_sequences
    return false if sequences.empty?

    @proteins = sequences.map.with_index(1) do |seq_data, index|
      {
        name: seq_data[:name],
        description: seq_data[:description],
        amino_acid_sequence: seq_data[:sequence],
        original_sequence: seq_data[:sequence],
        sequence_order: index
      }
    end

    validate_sequences
    @errors.empty?
  end

  def valid?
    @errors.empty?
  end

  private

  def valid_content?
    if @file_content.blank?
      @errors << "File is empty"
      return false
    end

    unless @file_content.include?(">")
      @errors << "File does not appear to be in FASTA format (no header lines found)"
      return false
    end

    true
  end

  def extract_sequences
    sequences = []
    current_header = nil
    current_sequence = ""

    @file_content.each_line do |line|
      line = line.strip

      if line.start_with?(">")
        # Save previous sequence if exists
        if current_header && !current_sequence.empty?
          sequences << process_sequence(current_header, current_sequence)
        end

        # Start new sequence
        current_header = line[1..-1] # Remove ">" character
        current_sequence = ""
      elsif !line.empty? && current_header
        # Accumulate sequence data
        current_sequence += line.upcase.gsub(/\s+/, "")
      end
    end

    # Don't forget the last sequence
    if current_header && !current_sequence.empty?
      sequences << process_sequence(current_header, current_sequence)
    end

    sequences
  end

  def process_sequence(header, sequence)
    # Parse header to extract name and description
    # Format: >ProteinName [description]
    # Or: >ProteinName description
    # Or: >ProteinName|description

    name_match = header.match(/^([^\s\[\|]+)/)
    name = name_match ? name_match[1] : "Protein"

    # Extract description from various formats
    description = ""
    if header.include?("[") && header.include?("]")
      desc_match = header.match(/\[([^\]]+)\]/)
      description = desc_match ? desc_match[1] : ""
    elsif header.include?("|")
      parts = header.split("|", 2)
      description = parts[1]&.strip || ""
    else
      # Everything after first whitespace
      parts = header.split(/\s+/, 2)
      description = parts[1] || ""
    end

    {
      name: name.strip,
      description: description.strip,
      sequence: clean_sequence(sequence)
    }
  end

  def clean_sequence(sequence)
    # Remove any non-amino acid characters except stop codon
    cleaned = sequence.gsub(/[^ARNDCEQGHILKMFPSTWYV\*]/i, "")

    # Ensure it ends with stop codon if it doesn't already
    unless cleaned.end_with?("*")
      cleaned += "*"
    end

    # Ensure it starts with methionine if it doesn't already
    unless cleaned.start_with?("M")
      cleaned = "M" + cleaned
    end

    cleaned.upcase
  end

  def validate_sequences
    # Use the same amino acid constant as the concern
    valid_acids = Protein::AMINO_ACIDS

    @proteins.each_with_index do |protein_data, index|
      sequence = protein_data[:amino_acid_sequence]

      # Check for minimum length
      if sequence.length < 3
        @errors << "Protein #{index + 1} (#{protein_data[:name]}): sequence too short (minimum 3 amino acids)"
      end

      # Check for valid amino acids
      invalid_chars = sequence.chars.uniq - valid_acids
      if invalid_chars.any?
        @errors << "Protein #{index + 1} (#{protein_data[:name]}): contains invalid amino acid codes: #{invalid_chars.join(', ')}"
      end

      # Warn about unusual sequences
      unless sequence.start_with?("M")
        @errors << "Protein #{index + 1} (#{protein_data[:name]}): does not start with methionine (M) - added automatically"
      end

      unless sequence.end_with?("*")
        @errors << "Protein #{index + 1} (#{protein_data[:name]}): does not end with stop codon (*) - added automatically"
      end
    end
  end
end
