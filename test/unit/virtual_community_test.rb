require File.dirname(__FILE__) + '/../test_helper'

class VirtualCommunityTest < Test::Unit::TestCase
  fixtures :virtual_communities

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

  def test_acts_as_configurable
    vc = VirtualCommunity.new(:name => 'Testing VirtualCommunity')
    assert_kind_of Array, vc.settings
    vc.settings[:some_setting] = 1
    assert vc.save
    assert_equal 1, vc.settings[:some_setting]
    assert_kind_of ConfigurableSetting, vc.settings.first
  end

  def test_features
    v = virtual_communities(:colivre_net)
    v.enable('feature1')
    assert v.enabled?('feature1')
    v.disable('feature1')
    assert !v.enabled?('feature1')
  end

end
