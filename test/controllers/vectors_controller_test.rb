require "test_helper"

class VectorsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect when not logged in" do
    get vectors_url
    assert_response :redirect
  end
end
