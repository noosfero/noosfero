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

  should 'be assigned to default environment if no environment is informed' do
    assert_equal Environment.default, Profile.create!(:name => 'my test profile', :identifier => 'mytestprofile').environment
  end

  should 'not override environment informed before creation' do
    env = Environment.create!(:name => 'My test environment')
    p = Profile.create!(:identifier => 'mytestprofile', :name => 'My test profile', :environment_id => env.id)

    assert_equal env, p.environment
  end

  should 'be able to set environment after instantiation and before creating' do
    env = Environment.create!(:name => 'My test environment')
    p = Profile.new(:identifier => 'mytestprofile', :name => 'My test profile')
    p.environment = env
    p.save!

    p.reload
    assert_equal env, p.environment
  end

  should 'set default environment for users created' do
    assert_equal Environment.default, create_user('mytestuser').person.environment
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

  def test_can_have_affiliated_people
    pr = Profile.create(:name => 'composite_profile', :identifier => 'composite')
    pe = User.create(:login => 'aff', :email => 'aff@pr.coop', :password => 'blih', :password_confirmation => 'blih').person
    
    member_role = Role.new(:name => 'new_member_role')
    assert member_role.save
    assert pr.affiliate(pe, member_role)

    assert pe.memberships.include?(pr)
  end

  def test_find_by_contents
    p = Profile.create(:name => 'wanted', :identifier => 'wanted')

    assert Profile.find_by_contents('wanted').include?(p)
    assert ! Profile.find_by_contents('not_wanted').include?(p)
  end

  should 'remove pages when removing profile' do
    profile = Profile.create!(:name => 'testing profile', :identifier => 'testingprofile')
    first = profile.articles.build(:name => 'first'); first.save!
    second = profile.articles.build(:name => 'second'); second.save!
    third = profile.articles.build(:name => 'third'); third.save!

    n = Article.count
    profile.destroy
    assert_equal n - 3, Article.count
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
    assert_invalid_identifier 'tag'
    assert_invalid_identifier 'cat'
  end

  should 'provide recent documents' do
    profile = Profile.create!(:name => 'testing profile', :identifier => 'testingprofile')
    first = profile.articles.build(:name => 'first'); first.save!
    second = profile.articles.build(:name => 'second'); second.save!
    third = profile.articles.build(:name => 'third'); third.save!

    assert_equal [first,second], profile.recent_documents(2)
    assert_equal [first,second,third], profile.recent_documents
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

  should 'be able to find profiles by their names with ferret' do
    small = Profile.create!(:name => 'A small profile for testing ', :identifier => 'smallprofilefortesting')
    big = Profile.create!(:name => 'A big profile for testing', :identifier => 'bigprofilefortesting')

    assert Profile.find_by_contents('small').include?(small)
    assert Profile.find_by_contents('big').include?(big)
    
    both = Profile.find_by_contents('profile testing')
    assert both.include?(small)
    assert both.include?(big)
  end

  should 'provide a shortcut for picking a profile by its identifier' do
    profile = Profile.create!(:name => 'bla', :identifier => 'testprofile')
    assert_equal profile, Profile['testprofile']
  end

  should 'have boxes and blocks upon creation' do
    profile = Profile.create!(:name => 'test profile', :identifier => 'testprofile')

    assert profile.boxes.size > 0
    assert profile.blocks.size > 0
  end

  should 'have at least one MainBlock upon creation' do
    profile = Profile.create!(:name => 'test profile', :identifier => 'testprofile')
    assert(profile.blocks.any? { |block| block.kind_of? MainBlock })
  end

  should 'remove boxes and blocks when removing profile' do
    profile = Profile.create!(:name => 'test profile', :identifier => 'testprofile')

    profile_boxes = profile.boxes.size
    profile_blocks = profile.blocks.size
    
    assert profile_boxes > 0
    assert profile_blocks > 0

    boxes = Box.count
    blocks = Block.count

    profile.destroy

    assert_equal boxes - profile_boxes, Box.count
    assert_equal blocks - profile_blocks, Block.count
  end

  should 'provide url to itself' do
    profile = Profile.create!(:name => "Test Profile", :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)

    assert_equal 'http://mycolivre.net/testprofile', profile.url
  end

  should 'generate URL' do
    profile = Profile.create!(:name => "Test Profile", :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)

    assert_equal 'http://mycolivre.net/profile/testprofile/friends', profile.generate_url(:controller => 'profile', :action => 'friends')
  end

  should 'provide URL options' do
    profile = Profile.create!(:name => "Test Profile", :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)

    assert_equal({:host => 'mycolivre.net', :profile => 'testprofile'}, profile.url_options)
  end

  should 'list tags for profile' do
    profile = Profile.create!(:name => "Test Profile", :identifier => 'testprofile')
    profile.articles.build(:name => 'first', :tag_list => 'first-tag').save!
    profile.articles.build(:name => 'second', :tag_list => 'first-tag, second-tag').save!
    profile.articles.build(:name => 'third', :tag_list => 'first-tag, second-tag, third-tag').save!

    assert_equal({ 'first-tag' => 3, 'second-tag' => 2, 'third-tag' => 1 }, profile.tags)

  end

  should 'find content tagged with given tag' do
    profile = Profile.create!(:name => "Test Profile", :identifier => 'testprofile')
    first = profile.articles.build(:name => 'first', :tag_list => 'first-tag'); first.save!
    second = profile.articles.build(:name => 'second', :tag_list => 'first-tag, second-tag'); second.save!
    third = profile.articles.build(:name => 'third', :tag_list => 'first-tag, second-tag, third-tag'); third.save!
    profile.reload

    assert_equivalent [ first, second, third], profile.find_tagged_with('first-tag')
    assert_equivalent [ second, third ], profile.find_tagged_with('second-tag')
    assert_equivalent [ third], profile.find_tagged_with('third-tag')
  end

  private

  def assert_invalid_identifier(id)
    profile = Profile.new(:identifier => id)
    assert !profile.valid?
    assert profile.errors.invalid?(:identifier)
  end
end
