require 'abstract_unit'

module ContentType
  class ImpliedController < ActionController::Base
    # Template's mime type is used if no content_type is specified

    self.view_paths = [ActionView::FixtureResolver.new(
      "content_type/implied/i_am_js_rjs.js.rjs" => "page.alert 'hello'"
    )]
  end
  
  class ImpliedContentTypeTest < Rack::TestCase
    test "sets Content-Type as text/javascript when rendering *.js" do
      get "/content_type/implied/i_am_js_rjs", "format" => "js"

      assert_header "Content-Type", "text/javascript; charset=utf-8"
    end
  end
end
