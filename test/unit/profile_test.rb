require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < Test::Unit::TestCase
  fixtures :profiles, :virtual_communities, :users

  def test_identifier_validation
    p = Profile.new
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'with space'
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'áéíóú'
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'rightformat2007'
    p.valid?
    assert ! p.errors.invalid?(:identifier)

    p.identifier = 'rightformat'
    p.valid?
    assert ! p.errors.invalid?(:identifier)

    p.identifier = 'right_format'
    p.valid?
    assert ! p.errors.invalid?(:identifier)
  end

  def test_has_domains
    p = Profile.new
    assert_kind_of Array, p.domains
  end

  def test_belongs_to_virtual_community_and_has_default
    p = Profile.new
    assert_kind_of VirtualCommunity, p.virtual_community
  end

  def test_can_have_user
    p = profiles(:johndoe)
    assert_kind_of User, p.user
  end

  def test_may_have_no_user
    p = profiles(:john_and_joe)
    assert_nil p.user
    assert p.valid?
  end

end
