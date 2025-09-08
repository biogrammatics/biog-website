require "test_helper"

class PichiaStrainsControllerTest < ActionDispatch::IntegrationTest
  test "should allow unauthenticated access to strains" do
    get pichia_strains_url
    assert_response :success
  end
end
