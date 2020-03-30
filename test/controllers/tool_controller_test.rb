require 'test_helper'

class ToolControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tool_index_url
    assert_response :success
  end

  test "should get settings" do
    get tool_settings_url
    assert_response :success
  end

  test "should get wordrand" do
    get tool_wordrand_url
    assert_response :success
  end

  test "should get yourand" do
    get tool_yourand_url
    assert_response :success
  end

  test "should get wordgen" do
    get tool_wordgen_url
    assert_response :success
  end

  test "should get redrand" do
    get tool_redrand_url
    assert_response :success
  end

  test "should get alpaca" do
    get tool_alpaca_url
    assert_response :success
  end

  test "should get cells" do
    get tool_cells_url
    assert_response :success
  end

  test "should get dither" do
    get tool_dither_url
    assert_response :success
  end

  test "should get lavalamp" do
    get tool_lavalamp_url
    assert_response :success
  end

  test "should get soundvisualiser" do
    get tool_soundvisualiser_url
    assert_response :success
  end

  test "should get replayer" do
    get tool_replayer_url
    assert_response :success
  end

  test "should get vic" do
    get tool_vic_url
    assert_response :success
  end

  test "should get bean" do
    get tool_bean_url
    assert_response :success
  end

  test "should get uwu" do
    get tool_uwu_url
    assert_response :success
  end

  test "should get crytyper" do
    get tool_crytyper_url
    assert_response :success
  end

  test "should get sarcasm" do
    get tool_sarcasm_url
    assert_response :success
  end

  test "should get css-streamliner" do
    get tool_css-streamliner_url
    assert_response :success
  end

end
