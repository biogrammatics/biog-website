class CheckoutController < ApplicationController
  before_action :require_authentication
  before_action :ensure_cart_has_items
  before_action :set_cart

  def new
    redirect_to address_step_checkout_index_path
  end

  def address_step
    @billing_address = Current.user.default_billing_address || Address.new(address_type: "billing")
    @shipping_address = Current.user.default_shipping_address || Address.new(address_type: "shipping")
    @use_billing_for_shipping = @billing_address.persisted? && @shipping_address.blank?

    if request.post?
      process_addresses
    end
  end

  def payment_step
    @billing_address = get_session_address(:billing) || Current.user.default_billing_address
    @shipping_address = get_session_address(:shipping) || Current.user.default_shipping_address
    
    unless @billing_address && @shipping_address
      redirect_to address_step_checkout_index_path, alert: "Please complete address information first."
      return
    end

    @order_summary = calculate_order_totals(@billing_address, @shipping_address)

    if request.post?
      # For now, just proceed to review - payment processing would go here
      redirect_to review_step_checkout_index_path
    end
  end

  def review_step
    @billing_address = get_session_address(:billing) || Current.user.default_billing_address
    @shipping_address = get_session_address(:shipping) || Current.user.default_shipping_address
    @order_summary = calculate_order_totals(@billing_address, @shipping_address)

    unless @billing_address && @shipping_address
      redirect_to address_step_checkout_index_path, alert: "Please complete checkout process from the beginning."
      return
    end

    if request.post?
      create_order
    end
  end

  def confirmation
    @order = Order.find(session[:last_order_id]) if session[:last_order_id]
    redirect_to root_path, alert: "Order not found." unless @order
  end

  private

  def set_cart
    @cart = Current.user.current_cart
  end

  def ensure_cart_has_items
    if authenticated? && Current.user.current_cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty."
    elsif !authenticated?
      redirect_to new_session_path(checkout: true)
    end
  end

  def process_addresses
    billing_params = params[:billing_address]&.permit(:first_name, :last_name, :company, :address_line_1, :address_line_2, :city, :state, :postal_code, :country, :phone)
    shipping_params = params[:shipping_address]&.permit(:first_name, :last_name, :company, :address_line_1, :address_line_2, :city, :state, :postal_code, :country, :phone)
    use_billing_for_shipping = params[:use_billing_for_shipping] == "1"

    errors = []

    # Validate and prepare billing address
    billing_address = Address.new(billing_params.merge(user: Current.user, address_type: "billing"))
    unless billing_address.valid?
      errors << "Billing address: #{billing_address.errors.full_messages.join(', ')}"
    end

    # Prepare shipping address
    if use_billing_for_shipping
      shipping_address = Address.new(billing_params.merge(user: Current.user, address_type: "shipping"))
    else
      shipping_address = Address.new(shipping_params.merge(user: Current.user, address_type: "shipping"))
    end
    
    unless shipping_address.valid?
      errors << "Shipping address: #{shipping_address.errors.full_messages.join(', ')}"
    end

    if errors.any?
      flash.now[:alert] = errors.join(" ")
      @billing_address = billing_address
      @shipping_address = shipping_address
      render :address_step
    else
      # Store addresses in session (don't save to DB until order is complete)
      session[:checkout_billing_address] = billing_address.attributes.except("id", "user_id", "created_at", "updated_at")
      session[:checkout_shipping_address] = shipping_address.attributes.except("id", "user_id", "created_at", "updated_at")
      redirect_to payment_step_checkout_index_path
    end
  end

  def get_session_address(type)
    return nil unless session["checkout_#{type}_address".to_sym]
    
    Address.new(session["checkout_#{type}_address".to_sym].merge(
      user: Current.user,
      address_type: type.to_s
    ))
  end

  def calculate_order_totals(billing_address, shipping_address)
    subtotal = @cart.total_price
    
    # Calculate tax based on shipping address
    tax_rate = calculate_tax_rate(shipping_address.state)
    tax_amount = subtotal * tax_rate
    
    # Calculate shipping
    shipping_cost = calculate_shipping_cost(shipping_address, @cart)
    
    total = subtotal + tax_amount + shipping_cost

    {
      subtotal: subtotal,
      tax_rate: tax_rate,
      tax_amount: tax_amount,
      shipping_cost: shipping_cost,
      total: total
    }
  end

  def calculate_tax_rate(state)
    # Simple tax calculation - in reality you'd use a tax service like Avalara or TaxJar
    state_tax_rates = {
      "CA" => 0.0725,   # California
      "NY" => 0.08,     # New York  
      "TX" => 0.0625,   # Texas
      "FL" => 0.06,     # Florida
      "WA" => 0.065,    # Washington
      "OR" => 0.0,      # Oregon (no sales tax)
      "NH" => 0.0,      # New Hampshire (no sales tax)
      "DE" => 0.0,      # Delaware (no sales tax)
      "MT" => 0.0,      # Montana (no sales tax)
      "AK" => 0.0       # Alaska (no state sales tax)
    }
    
    state_tax_rates[state] || 0.065  # Default 6.5% for other states
  end

  def calculate_shipping_cost(shipping_address, cart)
    # Simple shipping calculation - in reality you'd integrate with shipping carriers
    base_shipping = 15.00
    
    # Free shipping for orders over $150
    return 0 if cart.total_price >= 150
    
    # Add extra for Alaska and Hawaii
    if %w[AK HI].include?(shipping_address.state)
      base_shipping += 10.00
    end
    
    # Add $5 for each additional item over 3
    item_count = cart.total_items
    if item_count > 3
      base_shipping += (item_count - 3) * 5.00
    end
    
    base_shipping
  end

  def create_order
    billing_address = get_session_address(:billing)
    shipping_address = get_session_address(:shipping)
    order_summary = calculate_order_totals(billing_address, shipping_address)

    order = nil
    
    Order.transaction do
      # Save addresses to user account
      saved_billing = Current.user.addresses.create!(billing_address.attributes.except("id", "created_at", "updated_at"))
      saved_shipping = Current.user.addresses.create!(shipping_address.attributes.except("id", "created_at", "updated_at"))
      
      # Set as default if user doesn't have defaults
      saved_billing.set_as_default! unless Current.user.default_billing_address
      saved_shipping.set_as_default! unless Current.user.default_shipping_address
      
      # Create order
      order = Current.user.orders.create!(
        status: "pending",
        subtotal: order_summary[:subtotal],
        tax_amount: order_summary[:tax_amount],
        shipping_cost: order_summary[:shipping_cost],
        total_amount: order_summary[:total],
        billing_address: saved_billing.full_address,
        shipping_address: saved_shipping.full_address
      )
      
      # Create order items from cart
      @cart.cart_items.each do |cart_item|
        order.order_items.create!(
          item: cart_item.item,
          quantity: cart_item.quantity,
          price: cart_item.price
        )
      end
      
      # Clear the cart
      @cart.cart_items.destroy_all
    end

    # Clear checkout session
    session.delete(:checkout_billing_address)
    session.delete(:checkout_shipping_address)
    session[:last_order_id] = order.id

    redirect_to confirmation_checkout_index_path, notice: "Order placed successfully! Order ##{order.order_number}"
  rescue => e
    Rails.logger.error "Order creation failed: #{e.message}"
    redirect_to review_step_checkout_index_path, alert: "There was an error processing your order. Please try again."
  end
end