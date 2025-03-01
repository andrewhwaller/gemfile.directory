require "test_helper"

class GemfileTest < ActiveSupport::TestCase
  test "app_link must be a valid URL" do
    gemfile = Gemfile.new(
      app_link: "not_a_url"
    )
    assert_not gemfile.valid?, "Gemfile should be invalid with an invalid app link"
    assert gemfile.errors.of_kind? :app_link, :invalid
  end

  test "github_link must be a valid URL" do
    gemfile = Gemfile.new(
      github_link: "not_a_url"
    )
    assert_not gemfile.valid?, "Gemfile should be invalid with an invalid GitHub link"
    assert gemfile.errors.of_kind? :github_link, :invalid
  end

  test "content must contain at least one gem" do
    gemfile = Gemfile.new(
      content: "this string does not contain gems"
    )
    assert_not gemfile.valid?, "Gemfile should be invalid without a gem declaration"
    assert gemfile.errors.of_kind? :content, "must contain at least one gem"
  end

  test "parse_content should enqueue UpdateGemDataJob for each gem" do
    gemfile = Gemfile.new(
      content: "gem 'rails'\ngem 'sidekiq'"
    )

    assert_difference "ActiveJob::Base.queue_adapter.enqueued_jobs.count", 2 do
      gemfile.parse_content
    end
  end
end
