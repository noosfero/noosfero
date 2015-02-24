require_relative "../test_helper"

class MacroTest < ActiveSupport::TestCase

  class Plugin1 < Noosfero::Plugin
  end

  class Plugin1::Macro < Noosfero::Plugin::Macro
    def parse(params, inner_html, source)
      "Testing: #{inner_html}"
    end
  end

  MACRO = "<div class='macro nonEdit' data-macro='#{Plugin1::Macro.identifier}' data-macro-attr1='1' data-macro-attr2='2' data-macro-attr3='3'>It works!</div>"

  def setup
    @macro = Plugin1::Macro.new
    @macro_element = Nokogiri::HTML.fragment(MACRO).css('.macro').first
  end

  attr_reader :macro, :macro_element

  should 'access plugin' do
    assert_equal Plugin1, Plugin1::Macro.plugin
  end

  should 'parse attributes' do
    attributes = macro.attributes(macro_element)
    assert_equal '1', attributes['attr1']
    assert_equal '2', attributes['attr2']
    assert_equal '3', attributes['attr3']
  end

  should 'convert macro' do
    assert_equal 'Testing: It works!', macro.convert(macro_element, nil)
  end
end
