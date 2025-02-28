require "test_helper"

class AppGemTest < ActiveSupport::TestCase
  test "to_param returns name" do
    app_gem = AppGem.new(name: "rails")
    assert_equal app_gem.name, app_gem.to_param
  end

  test "homepage_uri returns homepage_uri from details" do
    app_gem = AppGem.new(details: { homepage_uri: "http://example.com" })
    assert_equal "http://example.com", app_gem.homepage_uri
  end
end
