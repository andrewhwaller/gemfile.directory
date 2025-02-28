require "test_helper"

class My::FavoritesControllerTest < ActionDispatch::IntegrationTest
  class UnauthenticatedTest < My::FavoritesControllerTest
    test "should redirect to root" do
      get my_favorites_url
      assert_redirected_to root_url
    end
  end

  class AuthenticatedTest < My::FavoritesControllerTest
    include OmniauthGithubHelper

    setup do
      valid_github_login_setup
      get "/auth/github/callback"
      assert_redirected_to root_path
    end

    test "should get index" do
      get my_favorites_url
      assert_response :success
    end
  end
end
