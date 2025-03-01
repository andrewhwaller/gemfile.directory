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
    # Store original method to restore after each test
    @original_method = Gems.method(:info)
  end

  teardown do
    # Ensure the original method is always restored
    if Gems.singleton_class.method_defined?(:info) && Gems.method(:info) != @original_method
      Gems.singleton_class.send(:remove_method, :info)
      Gems.define_singleton_method(:info, @original_method)
    end
  end

  test "updates gem details when gem exists" do
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

      # Assert that the details were updated, ignoring timestamp
      @mock_gem_data.each do |key, value|
        assert_equal value, @app_gem.details[key], "Expected details to contain #{key}=#{value}"
      end
      
      # Check that the timestamp was added
      assert @app_gem.details.key?("_fetched_at"), "Expected details to include _fetched_at timestamp"
    ensure
      # Restore original method
      Gems.singleton_class.send(:remove_method, :info)
      Gems.define_singleton_method(:info, @original_method)
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
      Gems.define_singleton_method(:info, @original_method)
    end
  end

  test "handles Gems::NotFound exception gracefully" do
    begin
      # Replace Gems.info with our mock implementation
      Gems.define_singleton_method(:info) do |name|
        raise Gems::NotFound.new("Gem not found")
      end

      # We expect this to raise the exception due to discard_on
      assert_raises Gems::NotFound do
        UpdateGemDataJob.new.perform(@app_gem.id)
      end

      # Reload the gem
      @app_gem.reload

      # Assert that details were updated with error information
      assert_equal 'not_found', @app_gem.details["error"]
      assert_equal 'Gem not found', @app_gem.details["message"]
      assert @app_gem.details.key?("_fetched_at")
    ensure
      # Restore original method
      Gems.singleton_class.send(:remove_method, :info)
      Gems.define_singleton_method(:info, @original_method)
    end
  end

  test "handles invalid gem data" do
    begin
      # Replace Gems.info to return invalid data (not a hash)
      Gems.define_singleton_method(:info) do |name|
        "Not a hash"
      end

      # Capture the original details
      original_details = @app_gem.details.dup
      
      # Perform the job
      UpdateGemDataJob.new.perform(@app_gem.id)

      # Reload the gem
      @app_gem.reload

      # Details should not have changed
      assert_equal original_details, @app_gem.details
    ensure
      # Restore original method
      Gems.singleton_class.send(:remove_method, :info)
      Gems.define_singleton_method(:info, @original_method)
    end
  end

  test "handles empty gem data" do
    begin
      # Replace Gems.info to return empty data
      Gems.define_singleton_method(:info) do |name|
        {}
      end

      # Capture the original details
      original_details = @app_gem.details.dup
      
      # Perform the job
      UpdateGemDataJob.new.perform(@app_gem.id)

      # Reload the gem
      @app_gem.reload

      # Details should not have changed
      assert_equal original_details, @app_gem.details
    ensure
      # Restore original method
      Gems.singleton_class.send(:remove_method, :info)
      Gems.define_singleton_method(:info, @original_method)
    end
  end
end
