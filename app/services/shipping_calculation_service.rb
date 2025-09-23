class ShippingCalculationService
  attr_reader :shipping_address, :cart

  BASE_SHIPPING = 15.00
  FREE_SHIPPING_THRESHOLD = 150.00
  ADDITIONAL_ITEM_COST = 5.00
  ADDITIONAL_ITEM_THRESHOLD = 3
  REMOTE_STATE_SURCHARGE = 10.00
  REMOTE_STATES = %w[AK HI].freeze

  def initialize(shipping_address, cart)
    @shipping_address = shipping_address
    @cart = cart
  end

  def call
    return 0 if free_shipping_eligible?

    base_cost = BASE_SHIPPING
    base_cost += remote_state_surcharge if remote_state?
    base_cost += additional_item_cost

    base_cost
  end

  private

  def free_shipping_eligible?
    cart.total_price >= FREE_SHIPPING_THRESHOLD
  end

  def remote_state?
    REMOTE_STATES.include?(shipping_address.state)
  end

  def remote_state_surcharge
    remote_state? ? REMOTE_STATE_SURCHARGE : 0
  end

  def additional_item_cost
    item_count = cart.total_items
    return 0 if item_count <= ADDITIONAL_ITEM_THRESHOLD

    (item_count - ADDITIONAL_ITEM_THRESHOLD) * ADDITIONAL_ITEM_COST
  end
end
