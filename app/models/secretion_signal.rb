class SecretionSignal < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :sequence, presence: true
  validates :organism, presence: true

  scope :active, -> { where(active: true) }
  scope :for_organism, ->(organism) { where(organism: organism) }

  def display_name
    "#{name} (#{organism})"
  end

  def sequence_length
    return 0 unless sequence.present?
    sequence.gsub(/\s+/, "").length
  end
end