ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mock_redis"
require "sidekiq/testing"

Sidekiq::Testing.fake!

class MockRedis
  alias_method :original_hmset, :hmset
  alias_method :original_setex, :setex
  alias_method :original_mset, :mset

  def hmset(key, *attrs)
    normalized_attrs = attrs.each_slice(2).map { |field, value| [ field, normalize_value(value) ] }.flatten
    original_hmset(key, *normalized_attrs)
  end

  def setex(key, ttl, value)
    value = normalize_value(value)
    original_setex(key, ttl, value)
  end

  def mset(*attrs)
    normalized_attrs = attrs.each_slice(2).map { |key, value| [ key, normalize_value(value) ] }.flatten
    original_mset(*normalized_attrs)
  end

  private

  def normalize_value(value)
    if value.is_a?(Hash) && value.default_proc
      value = value.to_h { |k, v| [k, v] } # Convert to a normal hash
    end
    value
  end
end

# Create a global MockRedis instance for consistency
MOCK_REDIS = MockRedis.new

Sidekiq.configure_server do |config|
  config.redis = { namespace: "sidekiq_test", url: MOCK_REDIS }
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: "sidekiq_test", url: MOCK_REDIS }
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    setup do
      @redis = MOCK_REDIS
      @redis.flushdb # Ensure Redis is empty at the start of each test
    end

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
