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
  
  def test_should_provide_access_to_homepage
    profile = Profile.create!(:identifier => 'newprofile', :name => 'New Profile')
    page = profile.homepage
    assert_kind_of Article, page
    assert_equal profile.identifier, page.slug
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
    
    member_role = Role.new(:name => 'member')
    assert member_role.save
    assert pr.affiliate(pe, member_role)

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

  def test_should_define_info
    assert_nil Profile.new.info
  end

  def test_should_avoid_reserved_identifiers
    assert_invalid_identifier 'admin'
    assert_invalid_identifier 'system'
    assert_invalid_identifier 'myprofile'
    assert_invalid_identifier 'profile'
    assert_invalid_identifier 'cms'
    assert_invalid_identifier 'community'
    assert_invalid_identifier 'test'
  end

  def test_should_provide_recent_documents
    profile = Profile.create!(:name => 'Testing Recent documents', :identifier => 'testing_recent_documents')
    doc1 = Article.new(:title => 'document 1', :body => 'la la la la la')
    doc1.parent = profile.homepage
    doc1.save!

    doc2 = Article.new(:title => 'document 2', :body => 'la la la la la')
    doc2.parent = profile.homepage
    doc2.save!

    docs = profile.recent_documents(2)
    assert_equal 2, docs.size
    assert docs.map(&:id).include?(doc1.id)
    assert docs.map(&:id).include?(doc2.id)
  end

  def test_should_provide_most_recent_documents
    profile = Profile.create!(:name => 'Testing Recent documents', :identifier => 'testing_recent_documents')
    doc1 = Article.new(:title => 'document 1', :body => 'la la la la la')
    doc1.parent = profile.homepage
    doc1.save!

    docs = profile.recent_documents(1)
    assert_equal 1, docs.size
    assert_equal doc1.id, docs.first.id
  end

  private

  def assert_invalid_identifier(id)
    profile = Profile.new(:identifier => id)
    assert !profile.valid?
    assert profile.errors.invalid?(:identifier)
  end

end
