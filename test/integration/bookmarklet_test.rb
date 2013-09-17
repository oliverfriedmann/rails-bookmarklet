require 'test_helper'

class BookmarkletTest < ActionDispatch::IntegrationTest

  test "the truth" do
    assert true
  end

  test "bookmarklet script generation" do
    get "/bookmarklet/show"
    assert_response :success
  end

  test "content type of bookmarklet script" do
    get "/bookmarklet/show"
    assert_equal Mime::JS, response.content_type
  end

end