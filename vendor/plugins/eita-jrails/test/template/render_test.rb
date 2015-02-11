require 'abstract_unit'

class TestController < ActionController::Base
end

module RenderTestCases
  def setup_view(paths)
    @assigns = { :secret => 'in the sauce' }
    @view = ActionView::Base.new(paths, @assigns)
    @controller_view = TestController.new.view_context

    # Reload and register danish language for testing
    I18n.reload!
    I18n.backend.store_translations 'da', {}
    I18n.backend.store_translations 'pt-BR', {}

    # Ensure original are still the same since we are reindexing view paths
    assert_equal ORIGINAL_LOCALES, I18n.available_locales.map {|l| l.to_s }.sort
  end

  def test_render_update
    assert_equal 'alert("Hello, World!");', @view.render(:update) { |page| page.alert('Hello, World!') }
  end
end
