require "test_helper"

class PichiaStrainsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get pichia_strains_index_url
    assert_response :success
  end

  test "should get show" do
    get pichia_strains_show_url
    assert_response :success
  end
end
