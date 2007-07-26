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
    assert_kind_of User, p.profile_owner
  end

  def test_may_have_no_user
    p = profiles(:john_and_joe)
    assert_nil p.profile_owner
    assert p.valid?
  end

  def test_only_one_profile_per_user
    p1 = profiles(:johndoe)
    assert_equal users(:johndoe), p1.profile_owner
    
    p2 = Profile.new
    p2.profile_owner = users(:johndoe)
    assert !p2.valid?
    assert p2.errors.invalid?(:profile_owner_id)
  end

  def test_several_profiles_without_user
    p1 = profiles(:john_and_joe)
    assert p1.valid?
    assert_nil p1.profile_owner

    p2 = Profile.new
    assert !p2.valid?
    assert !p2.errors.invalid?(:profile_owner_id)
  end

  def test_cannot_rename
    p1 = profiles(:johndoe)
    assert_raise ArgumentError do
      p1.identifier = 'bli'
    end
  end

end
