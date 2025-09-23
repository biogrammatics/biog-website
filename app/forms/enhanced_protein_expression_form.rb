class EnhancedProteinExpressionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :project_name, :string
  attribute :selected_vector_id, :integer
  attribute :notes, :string
  attribute :fasta_file
  attribute :input_method, :string, default: 'manual' # 'manual' or 'fasta'

  # For manual input
  attribute :proteins_attributes, default: -> { [{}] }

  validates :project_name, presence: true
  validates :selected_vector_id, presence: true
  validates :input_method, inclusion: { in: %w[manual fasta] }
  validate :validate_proteins_or_fasta
  validate :validate_vector_exists

  def initialize(user, attributes = {})
    @user = user
    super(attributes)
    ensure_default_protein if proteins_attributes.empty?
  end

  def proteins_attributes=(attrs)
    @proteins_attributes = attrs.is_a?(Array) ? attrs : attrs.values
  end

  def proteins_attributes
    @proteins_attributes ||= [{}]
  end

  def proteins
    @proteins ||= proteins_attributes.map.with_index do |attrs, index|
      ProteinForm.new(attrs.merge(sequence_order: index + 1))
    end
  end

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      @custom_project = @user.custom_projects.build(project_attributes)
      @custom_project.project_type = "protein_expression"

      if @custom_project.save
        handle_input_method
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

  def add_protein
    @proteins_attributes ||= []
    @proteins_attributes << {}
    self
  end

  def remove_protein(index)
    @proteins_attributes ||= []
    @proteins_attributes.delete_at(index) if @proteins_attributes.size > 1
    self
  end

  private

  attr_reader :user

  def project_attributes
    {
      project_name: project_name,
      selected_vector_id: selected_vector_id,
      notes: notes
    }
  end

  def ensure_default_protein
    @proteins_attributes = [{}] if @proteins_attributes.empty?
  end

  def validate_proteins_or_fasta
    if input_method == 'fasta'
      validate_fasta_input
    else
      validate_manual_input
    end
  end

  def validate_fasta_input
    if fasta_file.blank?
      errors.add(:fasta_file, "must be provided when using FASTA upload")
      return
    end

    # Validate file type
    unless fasta_file.content_type.in?(['text/plain', 'application/octet-stream', 'text/x-fasta'])
      errors.add(:fasta_file, "must be a text file (.fasta, .fas, .txt)")
      return
    end

    # Parse FASTA content
    begin
      content = fasta_file.read
      fasta_file.rewind # Reset file position

      parser = FastaParserService.new(content)
      unless parser.parse
        parser.errors.each { |error| errors.add(:fasta_file, error) }
      end
    rescue => e
      errors.add(:fasta_file, "could not be processed: #{e.message}")
    end
  end

  def validate_manual_input
    if proteins.empty? || proteins.all? { |p| p.amino_acid_sequence.blank? }
      errors.add(:base, "At least one protein sequence is required")
      return
    end

    proteins.each_with_index do |protein, index|
      unless protein.valid?
        protein.errors.each do |error|
          errors.add(:base, "Protein #{index + 1}: #{error.message}")
        end
      end
    end
  end

  def validate_vector_exists
    return unless selected_vector_id.present?

    unless Vector.exists?(selected_vector_id)
      errors.add(:selected_vector_id, "does not exist")
    end
  end

  def handle_input_method
    if input_method == 'fasta'
      process_fasta_file
    else
      create_proteins_from_manual_input
    end
  end

  def process_fasta_file
    # Attach the file
    @custom_project.fasta_file.attach(fasta_file)

    # Parse and create proteins
    content = fasta_file.read
    fasta_file.rewind

    parser = FastaParserService.new(content)
    if parser.parse
      parser.proteins.each do |protein_data|
        @custom_project.proteins.create!(protein_data)
      end

      @custom_project.update!(
        fasta_processed: true,
        fasta_processing_notes: "Successfully processed #{parser.proteins.count} proteins from FASTA file"
      )
    end
  end

  def create_proteins_from_manual_input
    proteins.each do |protein_form|
      next unless protein_form.amino_acid_sequence.present?

      @custom_project.proteins.create!(
        name: protein_form.name,
        description: protein_form.description,
        amino_acid_sequence: protein_form.amino_acid_sequence,
        original_sequence: protein_form.amino_acid_sequence,
        secretion_signal: protein_form.secretion_signal,
        n_terminal_tag: protein_form.n_terminal_tag,
        c_terminal_tag: protein_form.c_terminal_tag,
        sequence_order: protein_form.sequence_order
      )
    end
  end

  def copy_errors_from(model)
    model.errors.each do |error|
      errors.add(error.attribute, error.message) if respond_to?(error.attribute)
    end
  end

  # Nested form for individual proteins
  class ProteinForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :name, :string
    attribute :description, :string
    attribute :amino_acid_sequence, :string
    attribute :secretion_signal, :string
    attribute :n_terminal_tag, :string
    attribute :c_terminal_tag, :string
    attribute :sequence_order, :integer, default: 1

    validates :name, presence: true
    validates :amino_acid_sequence, presence: true
    validate :validate_amino_acid_sequence

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

    private

    def validate_amino_acid_sequence
      return unless amino_acid_sequence.present?

      cleaned_sequence = clean_amino_acid_sequence
      valid_acids = %w[A R N D C E Q G H I L K M F P S T W Y V *]

      # Check if sequence contains only valid amino acids
      invalid_chars = cleaned_sequence.chars.uniq - valid_acids
      if invalid_chars.any?
        errors.add(:amino_acid_sequence, "contains invalid amino acid codes: #{invalid_chars.join(', ')}")
      end

      # Check minimum length
      if cleaned_sequence.length < 2
        errors.add(:amino_acid_sequence, "must be at least 2 amino acids long")
      end
    end
  end
end