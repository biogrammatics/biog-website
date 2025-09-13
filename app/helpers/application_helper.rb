module ApplicationHelper
  def user_has_access_to_vector?(vector)
    return false unless authenticated?

    # Check if user has purchased this vector
    user_orders = Current.user.orders.joins(:order_items)
                              .where(order_items: { item_type: "Vector", item_id: vector.id })
                              .where(status: "completed")

    return true if user_orders.exists?

    # Check if user has an active subscription that includes this vector
    active_subscription = Current.user.current_subscription
    if active_subscription
      return active_subscription.subscription_vectors.exists?(vector: vector)
    end

    false
  end
end
