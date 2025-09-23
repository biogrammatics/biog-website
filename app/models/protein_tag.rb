class ProteinTag < ApplicationRecord
  TAG_TYPES = %w[n_terminal c_terminal].freeze

  validates :name, presence: true, uniqueness: { scope: :tag_type }
  validates :sequence, presence: true
  validates :tag_type, presence: true, inclusion: { in: TAG_TYPES }

  scope :active, -> { where(active: true) }
  scope :n_terminal, -> { where(tag_type: 'n_terminal') }
  scope :c_terminal, -> { where(tag_type: 'c_terminal') }

  def display_name
    "#{name} (#{tag_type.humanize})"
  end

  def sequence_length
    return 0 unless sequence.present?
    sequence.gsub(/\s+/, "").length
  end
end