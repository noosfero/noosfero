require File.dirname(__FILE__) + '/../test_helper'

class VirtualCommunityTest < Test::Unit::TestCase
  fixtures :virtual_communities

  def test_configuration
    c = VirtualCommunity.new
    assert_kind_of Hash, c.configuration
  end

end
