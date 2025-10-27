class PathwaySelection < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :service_package

  validates :step_number, presence: true, inclusion: { in: 1..6 }
  validates :selection_type, presence: true, inclusion: { in: %w[diy service] }
  validates :status, presence: true, inclusion: { in: %w[in_progress completed quoted] }

  scope :for_user, ->(user) { where(user: user) }
  scope :for_session, ->(session_id) { where(session_id: session_id) }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }
  scope :ordered, -> { order(:step_number) }

  # Get selections for a user or session
  def self.for_user_or_session(user, session_id)
    if user
      for_user(user).in_progress.ordered
    else
      for_session(session_id).in_progress.ordered
    end
  end

  def diy?
    selection_type == "diy"
  end

  def service?
    selection_type == "service"
  end
end
