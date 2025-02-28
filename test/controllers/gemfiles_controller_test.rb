require "test_helper"

class GemfilesControllerTest < ActionDispatch::IntegrationTest
  class UnauthenticatedTest < GemfilesControllerTest
    test "new should redirect to root" do
      get new_gemfile_url
      assert_redirected_to root_url
    end

    test "create should redirect to root" do
      post gemfiles_url, params: { gemfile: { content: "gem 'rails'" } }
      assert_redirected_to root_url
    end

    test "edit should redirect to root" do
      get edit_gemfile_url(gemfiles(:gemfile_one))
      assert_redirected_to root_url
    end

    test "update should redirect to root" do
      patch gemfile_url(gemfiles(:gemfile_one)), params: { gemfile: { content: "gem 'rails'" } }
      assert_redirected_to root_url
    end

    test "destroy should redirect to root" do
      delete gemfile_url(gemfiles(:gemfile_one))
      assert_redirected_to root_url
    end

    test "favorite should redirect to root" do
      post favorite_gemfile_url(gemfiles(:gemfile_one))
      assert_redirected_to root_url
    end

    test "unfavorite should redirect to root" do
      delete unfavorite_gemfile_url(gemfiles(:gemfile_one))
      assert_redirected_to root_url
    end

    test "should get index" do
      get gemfiles_url
      assert_response :success
    end

    test "should get show" do
      get gemfile_url(gemfiles(:gemfile_one))
      assert_response :success
    end

    test "should get gems_details" do
      get gems_details_gemfile_url(gemfiles(:gemfile_one))
      assert_response :success
    end
  end

  class AuthenticatedTest < GemfilesControllerTest
    include OmniauthGithubHelper

    setup do
      @logged_in_user = users(:user_one)
      authenticate(user: @logged_in_user)

      @authorized_gemfile = gemfiles(:gemfile_one)
      @unauthorized_gemfile = gemfiles(:gemfile_two)
    end

    test "should get new" do
      get new_gemfile_url
      assert_response :success
    end

    test "should create gemfile" do
      assert_difference("Gemfile.count") do
        post gemfiles_url, params: {
          gemfile: {
            content: "gem 'rails'",
            app_link: "https://example.com"
          }
        }
      end

      # Get the newly created gemfile
      new_gemfile = @logged_in_user.gemfiles.last
      
      # Verify we're redirected to the correct gemfile
      assert_redirected_to gemfile_url(new_gemfile)
    end

    test "should render new for invalid gemfile" do
      post gemfiles_url, params: {
        gemfile: {
          content: ""
        }
      }

      assert_response :unprocessable_entity
    end

    test "should get edit for authorized gemfile" do
      get edit_gemfile_url(@authorized_gemfile)
      assert_response :success
    end

    test "should redirect edit for unauthorized gemfile" do
      get edit_gemfile_url(@unauthorized_gemfile)
      assert_redirected_to gemfiles_url
    end

    test "should update authorized gemfile" do
      patch gemfile_url(@authorized_gemfile, params: {
        gemfile: {
          content: "gem 'rails'",
          app_link: "https://example.com"
        }
      })
      assert_redirected_to gemfile_url(@authorized_gemfile)
    end

    test "should render edit for invalid gemfile" do
      patch gemfile_url(@authorized_gemfile, params: {
        gemfile: {
          app_link: nil
        }
      })

      assert_response :unprocessable_entity
    end

    test "should redirect update for unauthorized gemfile" do
      patch gemfile_url(@unauthorized_gemfile, params: {
        gemfile: {
          content: "gem 'rails'",
          app_link: "https://example.com"
        }
      })
      assert_redirected_to gemfiles_url
    end

    test "should destroy authorized gemfile" do
      assert_difference("Gemfile.count", -1) do
        delete gemfile_url(@authorized_gemfile)
      end

      assert_redirected_to gemfiles_url
    end

    test "should redirect destroy for unauthorized gemfile" do
      assert_no_difference("Gemfile.count") do
        delete gemfile_url(@unauthorized_gemfile)
      end

      assert_redirected_to gemfiles_url
    end

    test "should favorite gemfile" do
      assert_difference("Favorite.count") do
        post favorite_gemfile_url(gemfiles(:gemfile_one))
      end

      assert_response :success
    end

    test "should unfavorite gemfile" do
      post favorite_gemfile_url(gemfiles(:gemfile_one))
      assert_difference("Favorite.count", -1) do
        delete unfavorite_gemfile_url(gemfiles(:gemfile_one))
      end

      assert_response :success
    end

    test "should get index" do
      get gemfiles_url
      assert_response :success
    end

    test "should get show" do
      get gemfile_url(gemfiles(:gemfile_one))
      assert_response :success
    end
  end
end
