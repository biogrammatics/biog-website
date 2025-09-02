require "test_helper"

class PichiaStrainsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect when not logged in" do
    get pichia_strains_url
    assert_response :redirect
  end
end
