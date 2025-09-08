require "test_helper"

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  # Subscriptions index allows unauthenticated access for browsing
  test "should allow unauthenticated access to subscriptions index" do
    get subscriptions_url
    assert_response :success
  end
end
