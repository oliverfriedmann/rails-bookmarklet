class BookmarkletController < ApplicationController
  include RailsBookmarklet

  def show
    render_bookmarklet("dummy", "sample")
  end

end