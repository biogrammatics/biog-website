require "test_helper"

class CartControllerTest < ActionDispatch::IntegrationTest
  # Cart now supports unauthenticated access with session-based storage
  test "should allow unauthenticated access to cart" do
    get cart_url
    assert_response :success
    assert_select "h3", "Shopping Cart"
  end

  test "unauthenticated cart should be empty initially" do
    get cart_url
    assert_response :success
    assert_select "h4", "Your cart is empty"
    assert_select "p", "Add some vectors or strains to get started!"
  end
end
