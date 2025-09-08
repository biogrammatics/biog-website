class CartController < ApplicationController
  allow_unauthenticated_access
  before_action :set_cart

  def show
    if authenticated?
      @cart_items = @cart.cart_items.includes(:item)
    else
      @cart_items = session_cart_items
    end
  end

  def add_item
    item_type = params[:item_type]
    item_id = params[:item_id]
    quantity = params[:quantity]&.to_i || 1

    # Find the item (Vector or PichiaStrain) - secure lookup
    case item_type
    when "Vector"
      item = Vector.find(item_id)
    when "PichiaStrain"
      item = PichiaStrain.find(item_id)
    else
      raise ActiveRecord::RecordNotFound, "Invalid item type"
    end

    # Add item to appropriate cart
    if authenticated?
      @cart.add_item(item, quantity)
    else
      add_item_to_session(item, quantity)
    end

    redirect_to cart_path, notice: "#{item.name} added to cart!"
  rescue ActiveRecord::RecordNotFound
    redirect_back(fallback_location: root_path, alert: "Item not found.")
  rescue NameError
    redirect_back(fallback_location: root_path, alert: "Invalid item type.")
  end

  def update_item
    if authenticated?
      cart_item = @cart.cart_items.find(params[:cart_item_id])
      quantity = params[:quantity].to_i

      if quantity > 0
        cart_item.update(quantity: quantity)
        redirect_to cart_path, notice: "Cart updated!"
      else
        cart_item.destroy
        redirect_to cart_path, notice: "Item removed from cart!"
      end
    else
      update_session_item(params[:item_key], params[:quantity].to_i)
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Cart item not found."
  end

  def remove_item
    if authenticated?
      cart_item = @cart.cart_items.find(params[:cart_item_id])
      item_name = cart_item.item_name
      cart_item.destroy
      redirect_to cart_path, notice: "#{item_name} removed from cart!"
    else
      remove_session_item(params[:item_key])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Cart item not found."
  end

  def clear
    if authenticated?
      @cart.cart_items.destroy_all
    else
      session[:cart] = {}
    end
    redirect_to cart_path, notice: "Cart cleared!"
  end

  def checkout
    if authenticated?
      # User is logged in, proceed with checkout
      redirect_to new_checkout_path
    else
      # Guest user, redirect to account creation with cart data preserved
      redirect_to new_session_path(checkout: true)
    end
  end

  private

  def set_cart
    @cart = authenticated? ? Current.user.current_cart : nil
  end

  # Session cart methods for guest users
  def session_cart
    session[:cart] ||= {}
  end

  def session_cart_items
    items = []
    session_cart.each do |key, item_data|
      item_type, item_id = key.split("_")

      begin
        case item_type
        when "Vector"
          item = Vector.find(item_id)
        when "PichiaStrain"
          item = PichiaStrain.find(item_id)
        else
          next
        end

        items << {
          key: key,
          item: item,
          quantity: item_data["quantity"],
          price: item_data["price"]
        }
      rescue ActiveRecord::RecordNotFound
        # Item no longer exists, remove from session
        session_cart.delete(key)
      end
    end
    items
  end

  def add_item_to_session(item, quantity)
    key = "#{item.class.name}_#{item.id}"

    if session_cart[key]
      session_cart[key]["quantity"] += quantity
    else
      session_cart[key] = {
        "quantity" => quantity,
        "price" => item.sale_price
      }
    end

    session.mark_as_loaded!
  end

  def update_session_item(key, quantity)
    if quantity > 0
      session_cart[key]["quantity"] = quantity
      redirect_to cart_path, notice: "Cart updated!"
    else
      session_cart.delete(key)
      redirect_to cart_path, notice: "Item removed from cart!"
    end
    session.mark_as_loaded!
  end

  def remove_session_item(key)
    item_data = session_cart[key]
    session_cart.delete(key)
    session.mark_as_loaded!
    redirect_to cart_path, notice: "Item removed from cart!"
  end

  def session_cart_total_items
    session_cart.sum { |key, item_data| item_data["quantity"] }
  end

  def session_cart_total_price
    session_cart.sum { |key, item_data| item_data["quantity"] * item_data["price"] }
  end
end
