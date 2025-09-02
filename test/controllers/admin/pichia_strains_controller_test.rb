require "test_helper"

class Admin::PichiaStrainsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_pichia_strains_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_pichia_strains_show_url
    assert_response :success
  end

  test "should get new" do
    get admin_pichia_strains_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_pichia_strains_create_url
    assert_response :success
  end

  test "should get edit" do
    get admin_pichia_strains_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_pichia_strains_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_pichia_strains_destroy_url
    assert_response :success
  end
end
