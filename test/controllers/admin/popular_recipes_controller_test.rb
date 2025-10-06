require "test_helper"

class Admin::PopularRecipesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_popular_recipes_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_popular_recipes_show_url
    assert_response :success
  end

  test "should get edit" do
    get admin_popular_recipes_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_popular_recipes_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_popular_recipes_destroy_url
    assert_response :success
  end
end
