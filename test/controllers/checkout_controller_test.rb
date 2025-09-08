require "test_helper"

class CheckoutControllerTest < ActionDispatch::IntegrationTest
  # Checkout requires authentication, so test that unauthorized users get redirected
  test "should redirect when not logged in for new" do
    get new_checkout_path
    assert_response :redirect
  end

  test "should redirect when not logged in for address_step" do
    get address_step_checkout_index_path
    assert_response :redirect
  end

  test "should redirect when not logged in for payment_step" do
    get payment_step_checkout_index_path
    assert_response :redirect
  end

  test "should redirect when not logged in for review_step" do
    get review_step_checkout_index_path
    assert_response :redirect
  end

  test "should redirect when not logged in for create" do
    post checkout_index_path
    assert_response :redirect
  end
end
