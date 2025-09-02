class Vector < ApplicationRecord
  belongs_to :promoter, optional: true
  belongs_to :selection_marker, optional: true
  belongs_to :vector_type, optional: true
  belongs_to :host_organism, optional: true
  belongs_to :product_status

  has_many_attached :files

  validates :name, presence: true, uniqueness: true
  validates :sale_price, presence: true, if: :available_for_sale?
  validates :subscription_price, presence: true, if: :available_for_subscription?

  scope :available_for_sale, -> { where(available_for_sale: true) }
  scope :available_for_subscription, -> { where(available_for_subscription: true) }
  scope :active, -> { joins(:product_status).where(product_statuses: { is_available: true }) }

  def available?
    product_status&.is_available?
  end

  def snapgene_file
    files.find { |file| file.filename.to_s.include?('.dna') }
  end

  def genbank_file
    files.find { |file| file.filename.to_s.include?('.gb') }
  end
end