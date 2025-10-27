class ServicePackage < ApplicationRecord
  has_many :pathway_selections, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :step_number, presence: true, inclusion: { in: 1..6 }
  validates :estimated_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :step_number) }
  scope :by_step, -> { order(:step_number) }
  scope :for_step, ->(step) { where(step_number: step) }

  # Generate slug from name before validation
  before_validation :generate_slug, if: -> { name.present? && slug.blank? }

  def diy?
    selection_type == "diy"
  end

  def service?
    selection_type == "service"
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
