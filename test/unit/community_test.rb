require File.dirname(__FILE__) + '/../test_helper'

class CommunityTest < Test::Unit::TestCase

  should 'inherit from Profile' do
    assert_kind_of Profile, Community.new
  end

  should 'convert name into identifier' do
    c = Community.new(:name =>'My shiny new Community')
    assert_equal 'My shiny new Community', c.name
    assert_equal 'my-shiny-new-community', c.identifier
  end

end
