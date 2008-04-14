require File.dirname(__FILE__) + '/../test_helper'

class TransliterationsTest < Test::Unit::TestCase

  def test_should_transliterate
    assert_equal 'eeeeEEOOoocaaaiIIiuuyYnN', 'éèëêÊËÖÔöôçäàâîÏÎïûüÿŸñÑ'.transliterate
  end


end
