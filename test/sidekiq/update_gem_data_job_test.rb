require "test_helper"
require "minitest/mock"

class UpdateGemDataJobTest < ActiveSupport::TestCase
  setup do
    @app_gem = app_gems(:app_gem_one)
    @mock_gem_data = {
      "name" => @app_gem.name,
      "info" => "Test gem description",
      "downloads" => 1000,
      "version" => "1.0.0",
      "homepage_uri" => "https://example.com/updated"
    }
  end

  test "updates gem details when gem exists" do
    # Save original method to restore it later
    original_method = Gems.method(:info)

    begin
      # Replace Gems.info with our mock implementation
      Gems.define_singleton_method(:info) do |name|
        @mock_gem_data
      end

      # Bind our mock data to the class
      Gems.instance_variable_set(:@mock_gem_data, @mock_gem_data)

      # Perform the job
      UpdateGemDataJob.new.perform(@app_gem.id)

      # Reload the gem to get updated attributes
      @app_gem.reload

      # Assert that the details were updated
      assert_equal @mock_gem_data, @app_gem.details
    ensure
      # Restore original method to avoid affecting other tests
      Gems.singleton_class.send(:remove_method, :info)
      Gems.define_singleton_method(:info, original_method)
    end
  end

  test "does nothing when app_gem doesn't exist" do
    # Generate a random UUID that doesn't exist in the database
    require "securerandom"
    non_existent_id = SecureRandom.uuid

    # Ensure this ID doesn't actually exist
    assert_nil AppGem.find_by(id: non_existent_id)

    # Create a flag to check if Gems.info is called
    was_called = false
    original_method = Gems.method(:info)

    begin
      # Replace Gems.info with our mock implementation
      Gems.define_singleton_method(:info) do |name|
        was_called = true
        raise "Gems.info should not be called"
      end

      # Perform the job
      UpdateGemDataJob.new.perform(non_existent_id)

      # Assert that Gems.info was not called
      assert_equal false, was_called
    ensure
      # Restore original method
      Gems.singleton_class.send(:remove_method, :info)
      Gems.define_singleton_method(:info, original_method)
    end
  end

  test "handles Gems::NotFound exception gracefully" do
    original_details = @app_gem.details.dup
    original_method = Gems.method(:info)

    begin
      # Replace Gems.info with our mock implementation
      Gems.define_singleton_method(:info) do |name|
        raise Gems::NotFound.new("Gem not found")
      end

      # Perform the job
      UpdateGemDataJob.new.perform(@app_gem.id)

      # Reload the gem
      @app_gem.reload

      # Assert that details were not changed
      assert_equal original_details, @app_gem.details
    ensure
      # Restore original method
      Gems.singleton_class.send(:remove_method, :info)
      Gems.define_singleton_method(:info, original_method)
    end
  end
end
