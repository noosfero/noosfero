require File.dirname(__FILE__) + '/../test_helper'

class LanguageHelperTest < Test::Unit::TestCase

  include LanguageHelper

  def test_english
    locale = mock
    locale.expects(:to_s).returns('en_us')
    GetText.stubs(:locale).returns(locale)
    
    assert_equal 'en', self.language
  end

  def test_other_languages
    locale = mock
    locale.expects(:to_s).returns('pt_BR')
    GetText.stubs(:locale).returns(locale)

    assert_equal 'pt_br', self.language
  end

end

