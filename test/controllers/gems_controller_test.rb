require "test_helper"

class GemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get gems_url
    assert_response :success
  end

  test "should get show" do
    get gem_url(app_gems(:app_gem_one))
    assert_response :success
  end

  test "should redirect to root if gem not found" do
    get gem_url("non_existent_gem")
    assert_redirected_to root_url
  end
end
