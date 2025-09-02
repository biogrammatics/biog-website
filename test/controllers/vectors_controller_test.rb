require "test_helper"

class VectorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get vectors_index_url
    assert_response :success
  end

  test "should get show" do
    get vectors_show_url
    assert_response :success
  end
end
