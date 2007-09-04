require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < Test::Unit::TestCase
  fixtures :profiles, :virtual_communities, :users, :comatose_pages

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

  def test_cannot_rename
    p1 = profiles(:johndoe)
    assert_raise ArgumentError do
      p1.identifier = 'bli'
    end
  end

  # when a profile called a page named after it  must also be created.
  def test_should_create_homepage_when_creating_profile
    Profile.create!(:identifier => 'newprofile', :name => 'New Profile')
    page = Comatose::Page.find_by_path('newprofile')
    assert_not_nil page
    assert_equal 'New Profile', page.title
  end

  def test_name_should_be_mandatory
    p = Profile.new
    p.valid?
    assert p.errors.invalid?(:name)
    p.name = 'a very unprobable name'
    p.valid?
    assert !p.errors.invalid?(:name)
  end

  def test_can_be_tagged
    p = Profile.create(:name => 'tagged_profile', :identifier => 'tagged')
    p.tags << Tag.create(:name => 'a_tag')
    assert Profile.find_tagged_with('a_tag').include?(p)
  end

  def test_can_have_affiliated_people
    pr = Profile.create(:name => 'composite_profile', :identifier => 'composite')
    pe = User.create(:login => 'aff', :email => 'aff@pr.coop', :password => 'blih', :password_confirmation => 'blih').person
    pr.people << pe

    assert pe.profiles.include?(pr)
  end

  def test_search
    p = Profile.create(:name => 'wanted', :identifier => 'wanted')
    p.update_attribute(:tag_list, 'bla')

    assert Profile.search('wanted').include?(p)
    assert Profile.search('bla').include?(p)
    assert ! Profile.search('not_wanted').include?(p)
  end

  def test_should_remove_pages_when_removing_profile
    profile = Profile.create(:name => 'To bee removed', :identifier => 'to_be_removed')
    assert Comatose::Page.find_by_path('to_be_removed')
    profile.destroy
    assert !Comatose::Page.find_by_path('to_be_removed')
  end

end
