require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to root if invalid user" do
    OmniAuth.config.mock_auth[:github] = :invalid_credentials
    get auth_github_callback_url
    follow_redirect!
    assert_redirected_to root_url
  end

  test "should delete session" do
    delete sign_out_url
    assert_redirected_to root_url
  end

  test "should redirect to root if failure" do
    OmniAuth.config.mock_auth[:github] = :invalid_credentials
    get auth_failure_url
    assert_redirected_to root_url
  end
end
