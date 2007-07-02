require File.dirname(__FILE__) + '/../test_helper'

class DomainTest < Test::Unit::TestCase
  fixtures :domains

  # Replace this with your real tests.
  def test_domain_name_format
    c = Domain.new
    c.valid?
    assert c.errors.invalid?(:domain)

    c.domain = 'bliblibli'
    c.valid?
    assert c.errors.invalid?(:domain)

    c.domain = 'test.net'
    c.valid?
    assert ! c.errors.invalid?(:domain)
  end

  def test_owner
    d = Domain.new(:name => 'example.com')
    d.owner = VirtualCommunity.new(:name => 'Example')
    assert d.save
    assert_kind_of VirtualCommunity, d.owner
  end

end
