require "test_helper"

class Admin::VectorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_vectors_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_vectors_show_url
    assert_response :success
  end

  test "should get new" do
    get admin_vectors_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_vectors_create_url
    assert_response :success
  end

  test "should get edit" do
    get admin_vectors_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_vectors_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_vectors_destroy_url
    assert_response :success
  end
end
