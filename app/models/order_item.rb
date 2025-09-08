class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item, polymorphic: true

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }

  def total_price
    price * quantity
  end

  def item_name
    item.name
  end

  def item_description
    case item_type
    when "Vector"
      "Expression vector - #{item.promoter&.name} promoter"
    when "PichiaStrain"
      "Pichia strain - #{item.genotype}"
    else
      item.description&.truncate(50)
    end
  end
end
