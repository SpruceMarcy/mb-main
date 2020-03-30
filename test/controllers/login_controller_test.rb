require 'test_helper'

class LoginControllerTest < ActionDispatch::IntegrationTest
  test "should get callback" do
    get login_callback_url
    assert_response :success
  end

  test "should get logout" do
    get login_logout_url
    assert_response :success
  end

end
