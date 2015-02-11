require 'abstract_unit'

class OldContentTypeController < ActionController::Base
  def render_default_for_rjs
  end
end

class ContentTypeTest < ActionController::TestCase
  tests OldContentTypeController

  def test_default_for_rjs
    xhr :post, :render_default_for_rjs
    assert_equal Mime::JS, @response.content_type
    assert_equal "utf-8", @response.charset
  end
end
