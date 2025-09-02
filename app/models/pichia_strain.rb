class PichiaStrain < ApplicationRecord
  belongs_to :strain_type, optional: true
  belongs_to :product_status

  has_many_attached :files

  validates :name, presence: true, uniqueness: true
  validates :sale_price, presence: true

  scope :available, -> { where(availability: "In Stock") }
  scope :active, -> { joins(:product_status).where(product_statuses: { is_available: true }) }

  def available?
    product_status&.is_available? && availability == "In Stock"
  end

  def certificate_file
    files.find { |file| file.filename.to_s.downcase.include?("certificate") }
  end

  def protocol_file
    files.find { |file| file.filename.to_s.downcase.include?("protocol") }
  end
end
