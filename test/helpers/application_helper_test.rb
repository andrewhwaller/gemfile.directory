require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "title should set content for title" do
    title("Test Title")
    assert_equal "Test Title", content_for(:title)
  end

  test "header_title should set content for header_title" do
    header_title("Test Header Title")
    assert_equal "Test Header Title", content_for(:header_title)
  end

  test "description should set content for description" do
    description("Test Description")
    assert_equal "Test Description", content_for(:description)
  end

  test "meta_image should set content for meta_image" do
    meta_image("test_image.jpg")
    assert_equal "test_image.jpg", content_for(:meta_image)
  end

  test "header_content should set content for header_content" do
    header_content { "Test Header Content" }
    assert_equal "Test Header Content", content_for(:header_content)
  end

  test "header_content? should return true when content exists" do
    header_content { "Test Header Content" }
    assert header_content?
  end

  test "header_content? should return false when no content exists" do
    assert_not header_content?
  end

  test "header_action should set content for header_action" do
    header_action { "Test Header Action" }
    assert_equal "Test Header Action", content_for(:header_action)
  end

  test "header_action? should return true when content exists" do
    header_action { "Test Header Action" }
    assert header_action?
  end

  test "header_action? should return false when no content exists" do
    assert_not header_action?
  end

  test "nav_link should return link with active class when current page" do
    def current_page?(path)
      path == "/active"
    end

    result = nav_link("Active Link", "/active")
    assert_includes result, "text-black"
    assert_includes result, "bg-amber-300"
  end

  test "nav_link should return link with inactive class when not current page" do
    def current_page?(path)
      path == "/active"
    end

    result = nav_link("Inactive Link", "/inactive")
    assert_includes result, "text-white"
    assert_includes result, "bg-neutral-800"
  end
end
