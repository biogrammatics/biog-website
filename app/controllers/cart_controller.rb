class CartController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(:item)
  end

  def add_item
    item_type = params[:item_type]
    item_id = params[:item_id]
    quantity = params[:quantity]&.to_i || 1

    # Find the item (Vector or PichiaStrain)
    item = item_type.constantize.find(item_id)
    
    # Add item to cart
    @cart.add_item(item, quantity)
    
    redirect_to cart_path, notice: "#{item.name} added to cart!"
  rescue ActiveRecord::RecordNotFound
    redirect_back(fallback_location: root_path, alert: "Item not found.")
  rescue NameError
    redirect_back(fallback_location: root_path, alert: "Invalid item type.")
  end

  def update_item
    cart_item = @cart.cart_items.find(params[:cart_item_id])
    quantity = params[:quantity].to_i

    if quantity > 0
      cart_item.update(quantity: quantity)
      redirect_to cart_path, notice: "Cart updated!"
    else
      cart_item.destroy
      redirect_to cart_path, notice: "Item removed from cart!"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Cart item not found."
  end

  def remove_item
    cart_item = @cart.cart_items.find(params[:cart_item_id])
    item_name = cart_item.item_name
    cart_item.destroy
    redirect_to cart_path, notice: "#{item_name} removed from cart!"
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "Cart item not found."
  end

  def clear
    @cart.cart_items.destroy_all
    redirect_to cart_path, notice: "Cart cleared!"
  end

  private

  def set_cart
    @cart = Current.user.current_cart
  end

  def authenticate_user!
    unless authenticated?
      redirect_to new_session_path, alert: "Please sign in to use the shopping cart."
    end
  end
end
