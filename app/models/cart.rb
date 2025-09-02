class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  def total_price
    cart_items.sum { |item| item.price * item.quantity }
  end

  def total_items
    cart_items.sum(:quantity)
  end

  def add_item(item, quantity = 1)
    existing_item = cart_items.find_by(item_type: item.class.name, item_id: item.id)

    if existing_item
      existing_item.update(quantity: existing_item.quantity + quantity)
      existing_item
    else
      cart_items.create!(
        item_type: item.class.name,
        item_id: item.id,
        quantity: quantity,
        price: item.sale_price
      )
    end
  end
end
