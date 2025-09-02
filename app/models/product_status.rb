class ProductStatus < ApplicationRecord
  has_many :vectors, dependent: :restrict_with_error
  has_many :pichia_strains, dependent: :restrict_with_error
  validates :name, presence: true, uniqueness: true
end