class CustomProject < ApplicationRecord
  belongs_to :user

  STATUSES = %w[pending in_progress completed cancelled].freeze
  PROJECT_TYPES = %w[strain_only strain_and_testing full_service consultation].freeze

  validates :project_name, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :project_type, inclusion: { in: PROJECT_TYPES }, allow_nil: true

  scope :pending, -> { where(status: "pending") }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }

  def total_services
    services = []
    services << "Custom Strain Generation" if strain_generation?
    services << "Expression Testing" if expression_testing?
    services
  end

  def display_status
    status.humanize
  end
end
