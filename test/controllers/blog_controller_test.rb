require 'test_helper'

class BlogControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get blog_index_url
    assert_response :success
  end

  test "should get edit" do
    get blog_edit_url
    assert_response :success
  end

  test "should get delete" do
    get blog_delete_url
    assert_response :success
  end

  test "should get add" do
    get blog_add_url
    assert_response :success
  end

  test "should get show" do
    get blog_show_url
    assert_response :success
  end

  test "should get aprilfools" do
    get blog_aprilfools_url
    assert_response :success
  end

end
