require "test_helper"

class AccountControllerTest < ActionDispatch::IntegrationTest
  # Account requires authentication, so just test that unauthorized users get redirected  
  test "should redirect when not logged in" do
    get account_url
    assert_response :redirect
  end
end