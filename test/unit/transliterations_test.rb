require File.dirname(__FILE__) + '/../test_helper'
require 'noosfero/transliterations'

class TransliterationsTest < Test::Unit::TestCase

  def test_should_transliterate
    assert_equal 'eeeeEEOOoocaaaiIIiuuyYnN', 'éèëêÊËÖÔöôçäàâîÏÎïûüÿŸñÑ'.transliterate
  end


end
