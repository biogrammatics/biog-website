class OrderCreationService
  attr_reader :user, :cart, :billing_address, :shipping_address, :errors

  def initialize(user:, cart:, billing_address:, shipping_address:)
    @user = user
    @cart = cart
    @billing_address = billing_address
    @shipping_address = shipping_address
    @errors = []
  end

  def call
    return false unless valid?

    create_order_with_transaction
  rescue => e
    Rails.logger.error "Order creation failed: #{e.message}"
    @errors << "There was an error processing your order. Please try again."
    false
  end

  def order_summary
    @order_summary ||= calculate_order_totals
  end

  private

  def valid?
    @errors = []
    @errors << "Billing address is required" unless billing_address
    @errors << "Shipping address is required" unless shipping_address
    @errors << "Cart is empty" if cart.cart_items.empty?
    @errors.empty?
  end

  def create_order_with_transaction
    order = nil

    Order.transaction do
      # Save addresses to user account
      saved_billing = save_address(billing_address, "billing")
      saved_shipping = save_address(shipping_address, "shipping")

      # Set as default if user doesn't have defaults
      saved_billing.set_as_default! unless user.default_billing_address
      saved_shipping.set_as_default! unless user.default_shipping_address

      # Create order
      order = create_order_record(saved_billing, saved_shipping)

      # Create order items from cart
      create_order_items(order)

      # Clear the cart
      cart.cart_items.destroy_all
    end

    order
  end

  def save_address(address, address_type)
    user.addresses.create!(
      address.attributes.except("id", "created_at", "updated_at").merge(
        address_type: address_type
      )
    )
  end

  def create_order_record(saved_billing, saved_shipping)
    user.orders.create!(
      status: "pending",
      subtotal: order_summary[:subtotal],
      tax_amount: order_summary[:tax_amount],
      shipping_cost: order_summary[:shipping_cost],
      total_amount: order_summary[:total],
      billing_address: saved_billing.full_address,
      shipping_address: saved_shipping.full_address
    )
  end

  def create_order_items(order)
    cart.cart_items.each do |cart_item|
      order.order_items.create!(
        item: cart_item.item,
        quantity: cart_item.quantity,
        price: cart_item.price
      )
    end
  end

  def calculate_order_totals
    subtotal = cart.total_price

    # Calculate tax based on shipping address
    tax_rate = TaxCalculationService.new(shipping_address.state).call
    tax_amount = subtotal * tax_rate

    # Calculate shipping
    shipping_cost = ShippingCalculationService.new(shipping_address, cart).call

    total = subtotal + tax_amount + shipping_cost

    {
      subtotal: subtotal,
      tax_rate: tax_rate,
      tax_amount: tax_amount,
      shipping_cost: shipping_cost,
      total: total
    }
  end
end