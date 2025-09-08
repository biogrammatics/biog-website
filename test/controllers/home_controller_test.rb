require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should allow unauthenticated access to home page" do
    get root_url
    assert_response :success
  end
end
