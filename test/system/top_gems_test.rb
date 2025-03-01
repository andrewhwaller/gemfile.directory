require "application_system_test_case"

class TopGemsTest < ApplicationSystemTestCase
  test "displays gems with correct counts in order" do
    # Clean existing data
    GemfileAppGem.destroy_all
    AppGem.destroy_all
    
    # Create just two gems with different counts
    rails = AppGem.create!(name: "rails", details: { "info" => "Ruby on Rails framework" })
    devise = AppGem.create!(name: "devise", details: { "info" => "Authentication" })
    
    # Create a user for the gemfiles
    user = users(:user_one)
    
    # Rails appears in 2 gemfiles
    2.times do |i|
      gemfile = user.gemfiles.create!(
        name: "Rails App #{i+1}",
        content: "gem 'rails'",
        app_link: "https://example.com/rails-#{i+1}",
        gem_count: 1
      )
      GemfileAppGem.create!(gemfile: gemfile, app_gem: rails)
    end
    
    # Devise appears in 1 gemfile
    gemfile = user.gemfiles.create!(
      name: "Devise App",
      content: "gem 'devise'",
      app_link: "https://example.com/devise",
      gem_count: 1
    )
    GemfileAppGem.create!(gemfile: gemfile, app_gem: devise)
    
    # Visit the top gems page
    visit top_gems_path
    
    # Verify the page title is present
    assert_selector "h1", text: "Most Popular Gems"
    
    # Get all gem list items
    gems = all("ul[role='list'] li")
    
    # Verify the order - rails (2 gemfiles) should be first, devise (1 gemfile) second
    assert_match(/rails/, gems.first.text)
    assert_match(/2 gemfiles/, gems.first.text)
    
    assert_match(/devise/, gems.last.text)
    assert_match(/1 gemfiles/, gems.last.text)
    
    # Verify gem info is displayed
    assert_text "Ruby on Rails framework"
  end
end 