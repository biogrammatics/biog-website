require "ostruct"

class SessionCartService
  attr_reader :session

  def initialize(session)
    @session = session
  end

  # Get session cart hash
  def cart
    session[:cart] ||= {}
  end

  # Get cart items as objects (optimized to avoid N+1 queries)
  def cart_items
    # Group cart keys by item type for batch loading
    vector_ids = []
    strain_ids = []

    cart.each_key do |key|
      item_type, item_id = key.split("_")
      case item_type
      when "Vector"
        vector_ids << item_id.to_i
      when "PichiaStrain"
        strain_ids << item_id.to_i
      end
    end

    # Batch load all items
    vectors = Vector.where(id: vector_ids).index_by(&:id)
    strains = PichiaStrain.where(id: strain_ids).index_by(&:id)

    # Build cart items array
    items = []
    cart.each do |key, item_data|
      item_type, item_id = key.split("_")

      item = case item_type
      when "Vector"
        vectors[item_id.to_i]
      when "PichiaStrain"
        strains[item_id.to_i]
      else
        next
      end

      # Skip if item no longer exists
      unless item
        remove_item(key)
        next
      end

      items << OpenStruct.new(
        item: item,
        quantity: item_data["quantity"],
        price: item_data["price"],
        total_price: item_data["quantity"] * item_data["price"],
        session_key: key
      )
    end

    items
  end

  # Add item to session cart
  def add_item(item, quantity = 1)
    key = generate_key(item)
    if cart[key]
      cart[key]["quantity"] += quantity
    else
      cart[key] = {
        "quantity" => quantity,
        "price" => item.sale_price || 0
      }
    end
    mark_session_as_loaded!
  end

  # Update item quantity
  def update_item(key, quantity)
    if quantity > 0
      cart[key]["quantity"] = quantity
    else
      remove_item(key)
    end
    mark_session_as_loaded!
  end

  # Remove item from cart
  def remove_item(key)
    cart.delete(key)
    mark_session_as_loaded!
  end

  # Clear entire cart
  def clear
    session[:cart] = {}
    mark_session_as_loaded!
  end

  # Get total number of items
  def total_items
    cart.sum { |key, item_data| item_data["quantity"] || 0 }
  end

  # Get total price
  def total_price
    cart.sum { |key, item_data|
      quantity = item_data["quantity"] || 0
      price = item_data["price"] || 0
      quantity * price
    }
  end

  # Check if cart is empty
  def empty?
    cart.empty?
  end

  # Check if item exists in cart
  def has_item?(item)
    key = generate_key(item)
    cart.key?(key)
  end

  # Get quantity of specific item
  def item_quantity(item)
    key = generate_key(item)
    cart.dig(key, "quantity") || 0
  end

  private

  def generate_key(item)
    "#{item.class.name}_#{item.id}"
  end

  def mark_session_as_loaded!
    session.mark_as_loaded! if session.respond_to?(:mark_as_loaded!)
  end
end
