require "test_helper"

class VectorsControllerTest < ActionDispatch::IntegrationTest
  test "should allow unauthenticated access to vectors" do
    get vectors_url
    assert_response :success
  end
end
