require 'test_helper'

class FileControllerTest < ActionDispatch::IntegrationTest
  test "should get image" do
    get file_image_url
    assert_response :success
  end

  test "should get sitemap" do
    get file_sitemap_url
    assert_response :success
  end

  test "should get robots" do
    get file_robots_url
    assert_response :success
  end

end
