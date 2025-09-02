require "test_helper"

class Admin::PichiaStrainsControllerTest < ActionDispatch::IntegrationTest
  # Admin pages require authentication and admin privileges
  test "should redirect when not logged in" do
    get admin_pichia_strains_url
    assert_response :redirect
  end
end