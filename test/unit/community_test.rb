require File.dirname(__FILE__) + '/../test_helper'

class CommunityTest < Test::Unit::TestCase

  should 'inherit from Profile' do
    assert_kind_of Profile, Community.new
  end

end
