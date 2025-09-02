class Promoter < ApplicationRecord
  has_many :vectors, dependent: :restrict_with_error
  validates :name, presence: true, uniqueness: true
end
