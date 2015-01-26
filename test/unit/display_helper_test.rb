require_relative "../test_helper"

class DisplayHelperTest < ActiveSupport::TestCase

  include DisplayHelper
  include ActionView::Helpers::TagHelper

  #### product_path related tests ####

  # TODO: product_path has no tests!

  #### txt2html related tests ####

  should 'show txt line-breaks' do
    html = txt2html "Bli\n123"
    assert_equal "Bli\n<br/>\n123", html
    html = txt2html "Bli\n123 456\nabc"
    assert_equal "Bli\n<br/>\n123 456\n<br/>\nabc", html
  end

  should 'replace empty lines as paragraphs separators' do
    html = txt2html "Bli\n\n123"
    assert_equal "Bli\n<p/>\n123", html
    html = txt2html "Bli \n \n 123"
    assert_equal "Bli\n<p/>\n123", html
  end

  should 'trim txt before convert to html' do
    html = txt2html "\nBli\n123\n"
    assert_equal "Bli\n<br/>\n123", html
    html = txt2html " Bli\n123 "
    assert_equal "Bli\n<br/>\n123", html
    html = txt2html " \nBli\n123\n "
    assert_equal "Bli\n<br/>\n123", html
  end

  should 'linkify "http://" prepended words on txt2html' do
    html = txt2html "go to http://noosfero.org"
    assert_equal 'go to <a href="http://noosfero.org" onclick="return confirm(\'Are you sure you want to visit this web site?\')" rel="nofolow" target="_blank">noos&#x200B;fero&#x200B;.org</a>', html
  end

  should 'linkify "www." prepended words on txt2html' do
    html = txt2html "go to www.noosfero.org yeah!"
    assert_equal 'go to <a href="http://www.noosfero.org" onclick="return confirm(\'Are you sure you want to visit this web site?\')" rel="nofolow" target="_blank">www.&#x200B;noos&#x200B;fero&#x200B;.org</a> yeah!', html
  end

  should 'return path to file under theme dir if theme has that file' do
    stubs(:theme_path).returns('/designs/themes/noosfero')
    assert_equal '/designs/themes/noosfero/images/rails.png', themed_path('/images/rails.png')
  end

  should 'return path to file under public dir if theme hasnt that file' do
    stubs(:theme_path).returns('/designs/themes/noosfero')
    assert_equal '/images/invalid-file.png', themed_path('/images/invalid-file.png')
  end

end
