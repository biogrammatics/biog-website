require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  # Subscriptions require authentication, so just test that unauthorized users get redirected
  test "should redirect when not logged in" do
    get subscriptions_url
    assert_response :redirect
  end
end