require 'abstract_unit'

class RenderJSTest < ActionController::TestCase
  class TestController < ActionController::Base
    protect_from_forgery

    def self.controller_path
      'test'
    end

    def greeting
      # let's just rely on the template
    end
  end

  tests TestController

  def test_render_with_default_from_accept_header
    xhr :get, :greeting
    assert_equal "$(\"body\").visualEffect(\"highlight\");", @response.body
  end
end
