require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to sign in when not authenticated" do
    get root_url
    assert_response :redirect
    assert_redirected_to new_session_url
  end
end
