class HostOrganism < ApplicationRecord
  has_many :vectors, dependent: :restrict_with_error
  validates :common_name, presence: true, uniqueness: true
end
