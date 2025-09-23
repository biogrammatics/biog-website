require "test_helper"

class VectorPricingTest < ActiveSupport::TestCase
  def setup
    @product_status = ProductStatus.create!(name: "Available", is_available: true)
    @vector = Vector.create!(
      name: "Test Vector",
      description: "A test vector for pricing",
      category: "Heterologous Protein Expression",
      available_for_sale: true,
      available_for_subscription: true,
      sale_price: 100.00,
      subscription_price: 50.00,
      product_status: @product_status
    )
  end

  test "can_be_deleted? returns true when vector is not purchased or in subscriptions" do
    assert @vector.can_be_deleted?
  end

  test "has_been_purchased? returns false when OrderItem doesn't exist" do
    assert_not @vector.has_been_purchased?
  end

  test "purchase_count returns 0 when no purchases" do
    assert_equal 0, @vector.purchase_count
  end

  test "in_subscriptions? returns false when no subscriptions" do
    assert_not @vector.in_subscriptions?
  end

  # These tests would require proper fixtures and more complex setup
  # for the Order/OrderItem relationship testing

  test "available? delegates to product_status" do
    assert @vector.available?

    unavailable_status = ProductStatus.create!(name: "Unavailable", is_available: false)
    @vector.update!(product_status: unavailable_status)
    assert_not @vector.available?
  end

  test "formatted_price shows dollar amount for sale vectors" do
    assert_equal "$100.0", @vector.formatted_price
  end

  test "formatted_price shows contact message for non-sale vectors" do
    @vector.update!(available_for_sale: false)
    assert_equal "Contact for pricing", @vector.formatted_price
  end

  test "price returns sale_price" do
    assert_equal @vector.sale_price, @vector.price
  end

  test "available_for_sale scope includes sale vectors" do
    assert_includes Vector.available_for_sale, @vector
  end

  test "available_for_subscription scope includes subscription vectors" do
    assert_includes Vector.available_for_subscription, @vector
  end
end