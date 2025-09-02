require "test_helper"

class CartControllerTest < ActionDispatch::IntegrationTest
  # Cart requires authentication, so just test that unauthorized users get redirected
  test "should redirect when not logged in" do
    get cart_url
    assert_response :redirect
  end
end
