require File.dirname(__FILE__) + '/../test_helper'

class VirtualCommunityTest < Test::Unit::TestCase
  fixtures :virtual_communities

  def test_features
    c = VirtualCommunity.new
    assert_kind_of Hash, c.features
  end

  def test_domain_validation
    c = VirtualCommunity.new
    c.valid?
    assert c.errors.invalid?(:domain)

    c.domain = 'bliblibli'
    c.valid?
    assert c.errors.invalid?(:domain)

    c.domain = 'test.net'
    c.valid?
    assert ! c.errors.invalid?(:domain)
  end


end
