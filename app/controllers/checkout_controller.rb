class CheckoutController < ApplicationController
  include CountriesHelper

  before_action :require_authentication
  before_action :ensure_cart_has_items
  before_action :set_cart

  def new
    redirect_to address_step_checkout_index_path
  end

  def address_step
    # Try to get saved addresses first, otherwise create new ones with prefilled data
    @billing_address = Current.user.default_billing_address || build_prefilled_address("billing")
    @shipping_address = Current.user.default_shipping_address || build_prefilled_address("shipping")
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
    service = OrderCreationService.new(
      user: Current.user,
      cart: @cart,
      billing_address: billing_address,
      shipping_address: shipping_address
    )
    service.order_summary
  end


  def create_order
    billing_address = get_session_address(:billing)
    shipping_address = get_session_address(:shipping)

    service = OrderCreationService.new(
      user: Current.user,
      cart: @cart,
      billing_address: billing_address,
      shipping_address: shipping_address
    )

    order = service.call

    if order
      # Clear checkout session
      session.delete(:checkout_billing_address)
      session.delete(:checkout_shipping_address)
      session[:last_order_id] = order.id

      redirect_to confirmation_checkout_index_path, notice: "Order placed successfully! Order ##{order.order_number}"
    else
      redirect_to review_step_checkout_index_path, alert: service.errors.join(", ")
    end
  end

  def build_prefilled_address(address_type)
    # Get the most recent address of this type for the user
    recent_address = Current.user.addresses.where(address_type: address_type).order(created_at: :desc).first

    if recent_address
      # Clone the recent address (without id) for editing
      Address.new(recent_address.attributes.except("id", "created_at", "updated_at", "is_default"))
    else
      # Create new address with user's basic info prefilled
      Address.new(
        address_type: address_type,
        first_name: Current.user.first_name,
        last_name: Current.user.last_name,
        country: "United States", # Default to US
        # Try to get phone from any existing address
        phone: Current.user.addresses.where.not(phone: nil).first&.phone
      )
    end
  end
end
