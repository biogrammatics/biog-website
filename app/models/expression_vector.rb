class ExpressionVector < ApplicationRecord
  has_many :custom_projects, foreign_key: :selected_vector_id, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :promoter, presence: true
  validates :drug_selection, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  scope :available, -> { where(available: true) }
  scope :protein_expression, -> { where(vector_type: "protein_expression") }

  def display_name
    "#{name} (#{promoter}/#{drug_selection})"
  end

  def feature_list
    return [] if features.blank?
    features.split(",").map(&:strip)
  end

  def formatted_price
    "$#{price.to_f}"
  end
end
