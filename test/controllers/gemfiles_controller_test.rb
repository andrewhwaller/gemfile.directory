require "test_helper"

class GemfilesControllerTest < ActionDispatch::IntegrationTest
  include OmniauthGithubHelper

  setup do
    valid_github_login_setup
    get "/auth/github/callback"
    assert_redirected_to root_path
  end

  test "should get index" do
    get gemfiles_url
    assert_response :success
  end

  test "should get new" do
    get new_gemfile_url
    assert_response :success
  end
end
