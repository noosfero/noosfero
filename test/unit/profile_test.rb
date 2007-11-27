require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < Test::Unit::TestCase
  fixtures :profiles, :environments, :users

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

  def test_belongs_to_environment_and_has_default
    p = Profile.new
    assert_kind_of Environment, p.environment
  end

  def test_cannot_rename
    assert_valid p = Profile.create(:name => 'new_profile', :identifier => 'new_profile')
    assert_raise ArgumentError do
      p.identifier = 'other_profile'
    end
  end
 
  should 'provide access to home page' do
    profile = Profile.create!(:identifier => 'newprofile', :name => 'New Profile')
    assert_nil profile.home_page

    page = profile.articles.build(:name => "My custom home page")
    page.save!

    profile.home_page = page
    profile.save!

    assert_equal page, profile.home_page
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
    
    member_role = Role.new(:name => 'new_member_role')
    assert member_role.save
    assert pr.affiliate(pe, member_role)

    assert pe.memberships.include?(pr)
  end

  def test_search
    p = Profile.create(:name => 'wanted', :identifier => 'wanted')
    p.update_attribute(:tag_list, 'bla')

    assert Profile.search('wanted').include?(p)
    assert Profile.search('bla').include?(p)
    assert ! Profile.search('not_wanted').include?(p)
  end

  def test_should_remove_pages_when_removing_profile
    flunk 'pending'
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
    flunk 'pending'
  end

  def test_should_provide_most_recent_documents
    flunk 'pending'
  end

  should 'affiliate and provide a list of the affiliated users' do
    profile = Profile.create!(:name => 'Profile for testing ', :identifier => 'profilefortesting')
    person = create_user('test_user').person
    role = Role.create!(:name => 'just_another_test_role')
    assert profile.affiliate(person, role)
    assert profile.members.map(&:id).include?(person.id)
  end

  should 'authorize users that have permission on the environment' do
    env = Environment.create!(:name => 'test_env')
    profile = Profile.create!(:name => 'Profile for testing ', :identifier => 'profilefortesting', :environment => env)
    person = create_user('test_user').person
    role = Role.create!(:name => 'just_another_test_role', :permissions => ['edit_profile'])
    assert env.affiliate(person, role)
    assert person.has_permission?('edit_profile', profile)
  end

  should 'have articles' do
    env = Environment.create!(:name => 'test_env')
    profile = Profile.create!(:name => 'Profile for testing ', :identifier => 'profilefortesting', :environment => env)

    assert_raise ActiveRecord::AssociationTypeMismatch do
      profile.articles << 1
    end
    
    assert_nothing_raised do
      profile.articles << Article.new(:name => 'testing article')
    end
  end

  should 'list top-level articles' do
    env = Environment.create!(:name => 'test_env')
    profile = Profile.create!(:name => 'Profile for testing ', :identifier => 'profilefortesting', :environment => env)

    p1 = profile.articles.build(:name => 'parent1')
    p1.save!
    p2 = profile.articles.build(:name => 'parent2')
    p2.save!

    child = profile.articles.build(:name => 'parent2', :parent_id => p1.id)
    child.save!

    top = profile.top_level_articles
    assert top.include?(p1)
    assert top.include?(p2)
    assert !top.include?(child)
  end

  should 'be able to optionally reload the list of top level articles' do
    env = Environment.create!(:name => 'test_env')
    profile = Profile.create!(:name => 'Profile for testing ', :identifier => 'profilefortesting', :environment => env)

    list = profile.top_level_articles
    same_list = profile.top_level_articles
    assert_same list, same_list

    other_list = profile.top_level_articles(true)
    assert_not_same list, other_list
  end

  private

  def assert_invalid_identifier(id)
    profile = Profile.new(:identifier => id)
    assert !profile.valid?
    assert profile.errors.invalid?(:identifier)
  end
end
