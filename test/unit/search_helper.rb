require File.dirname(__FILE__) + '/../test_helper'

class SearchHelperTest < Test::Unit::TestCase

  def setup
    @profile = mock
    @helper = mock
    helper.extend(SearchHelper)
  end
  attr_reader :profile, :helper

  should 'display profile info'

end
