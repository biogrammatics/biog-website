class CartController < ApplicationController
  allow_unauthenticated_access
  before_action :set_cart

  def show
    if authenticated?
      @cart_items = @cart.cart_items.includes(:item)
    else
      @cart_items = session_cart_service.cart_items
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
      session_cart_service.add_item(item, quantity)
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
      session_cart_service.update_item(params[:item_key], params[:quantity].to_i)
      redirect_to cart_path, notice: quantity > 0 ? "Cart updated!" : "Item removed from cart!"
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
      session_cart_service.remove_item(params[:item_key])
      redirect_to cart_path, notice: "Item removed from cart!"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Cart item not found."
  end

  def clear
    if authenticated?
      @cart.cart_items.destroy_all
    else
      session_cart_service.clear
    end
    redirect_to cart_path, notice: "Cart cleared!"
  end

  def checkout
    if authenticated?
      # User is logged in, proceed to checkout flow
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

  def session_cart_service
    @session_cart_service ||= SessionCartService.new(session)
  end
end
