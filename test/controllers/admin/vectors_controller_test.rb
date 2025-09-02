require "test_helper"

class Admin::VectorsControllerTest < ActionDispatch::IntegrationTest
  # Admin pages require authentication and admin privileges
  test "should redirect when not logged in" do
    get admin_vectors_url
    assert_response :redirect
  end
end
