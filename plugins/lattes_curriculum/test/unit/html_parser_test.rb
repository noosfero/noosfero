require "test_helper"

class HtmlParserTest < ActiveSupport::TestCase

  def setup
    @parser = Html_parser.new
  end
 
  should 'be not nil the instance' do
    assert_not_nil @parser
  end

  should 'be not nil the return get_html' do
    assert_not_nil @parser.get_html("http://lattes.cnpq.br/2193972715230641")
  end

  should 'return a string the return get_html' do
    assert_equal "", @parser.get_html()
  end

end
