require "simplecov"
SimpleCov.start

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    module OmniauthGithubHelper
      def valid_github_login_setup
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(Faker::Omniauth.github)
        Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
      end

      def authenticate(user:)
        # Set up OmniAuth test mode
        OmniAuth.config.test_mode = true

        # Create auth hash that matches the user's data
        auth_hash = OmniAuth::AuthHash.new(
          provider: user.provider,
          uid: user.uid,
          info: {
            email: user.email,
            name: user.name,
            image: user.image,
            nickname: user.github_username
          }
        )

        # Set up the auth hash in the test environment
        OmniAuth.config.mock_auth[:github] = auth_hash
        Rails.application.env_config["omniauth.auth"] = auth_hash

        # Simulate the OAuth callback
        get "/auth/github/callback"
        follow_redirect!
      end
    end
  end
end
