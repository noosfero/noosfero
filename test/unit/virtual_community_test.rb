require File.dirname(__FILE__) + '/../test_helper'

class VirtualCommunityTest < Test::Unit::TestCase
  fixtures :virtual_communities

  def test_configuration
    vc = VirtualCommunity.new
    assert_kind_of Hash, vc.configuration
  end

  def test_exists_default_and_it_is_unique
    VirtualCommunity.delete_all
    vc = VirtualCommunity.new(:name => 'Test Community')
    vc.is_default = true
    assert vc.save

    vc2 = VirtualCommunity.new(:name => 'Another Test Community')
    vc2.is_default = true
    assert !vc2.valid?
    assert vc2.errors.invalid?(:is_default)

    assert_equal vc, VirtualCommunity.default
  end

end
