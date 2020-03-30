require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_index_url
    assert_response :success
  end

  test "should get cv" do
    get admin_cv_url
    assert_response :success
  end

  test "should get database" do
    get admin_database_url
    assert_response :success
  end

  test "should get todo" do
    get admin_todo_url
    assert_response :success
  end

  test "should get photoview" do
    get admin_photoview_url
    assert_response :success
  end

  test "should get photoupload" do
    get admin_photoupload_url
    assert_response :success
  end

end
