require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < Test::Unit::TestCase
  fixtures :profiles, :environments, :users, :roles

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

    p.identifier = 'identifier-with-dashes'
    p.valid?
    assert ! p.errors.invalid?(:identifier), 'Profile should accept identifier with dashes'
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
    assert_kind_of Article, profile.home_page
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

    total = Article.count
    mine = profile.articles.count
    profile.destroy
    assert_equal total - mine, Article.count
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
    assert_invalid_identifier 'webmaster'
    assert_invalid_identifier 'info'
  end

  should 'provide recent documents' do
    profile = Profile.create!(:name => 'testing profile', :identifier => 'testingprofile')
    profile.articles.destroy_all

    first = profile.articles.build(:name => 'first'); first.save!
    second = profile.articles.build(:name => 'second'); second.save!
    third = profile.articles.build(:name => 'third'); third.save!

    assert_equal [third, second], profile.recent_documents(2)
    assert_equal [third, second, first], profile.recent_documents
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

  should 'have boxes upon creation' do
    profile = Profile.create!(:name => 'test profile', :identifier => 'testprofile')

    assert profile.boxes.size > 0
  end

  should 'remove boxes and blocks when removing profile' do
    profile = Profile.create!(:name => 'test profile', :identifier => 'testprofile')
    profile.boxes.first.blocks << MainBlock.new

    profile_boxes = profile.boxes.size
    profile_blocks = profile.blocks.size
    
    assert profile_boxes > 0, 'profile should have some boxes'
    assert profile_blocks > 0, 'profile should have some blocks'

    boxes = Box.count
    blocks = Block.count

    profile.destroy

    assert_equal boxes - profile_boxes, Box.count
    assert_equal blocks - profile_blocks, Block.count
  end

  should 'provide url to itself' do
    profile = Profile.create!(:name => "Test Profile", :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)

    assert_equal({ :host => 'mycolivre.net', :profile => 'testprofile', :controller => 'content_viewer', :action => 'view_page', :page => []}, profile.url)
  end

  should 'provide URL to admin area' do
    profile = Profile.create!(:name => "Test Profile", :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)
    assert_equal({ :host => 'mycolivre.net', :profile => 'testprofile', :controller => 'profile_editor', :action => 'index'}, profile.admin_url)
  end

  should 'provide URL to public profile' do
    profile = Profile.create!(:name => "Test Profile", :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)
    assert_equal({ :host => 'mycolivre.net', :profile => 'testprofile', :controller => 'profile', :action => 'index' }, profile.public_profile_url)
  end

  should 'generate URL' do
    profile = Profile.create!(:name => "Test Profile", :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)

    assert_equal({ :host => 'mycolivre.net', :profile => 'testprofile', :controller => 'profile', :action => 'friends' }, profile.generate_url(:controller => 'profile', :action => 'friends'))
  end

  should 'provide URL options' do
    profile = Profile.create!(:name => "Test Profile", :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)

    assert_equal({:host => 'mycolivre.net', :profile => 'testprofile'}, profile.url_options)
  end

  should 'help developers by adding a suitable port to url options' do
    profile = Profile.create!(:name => "Test Profile", :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)

    ENV.expects(:[]).with('RAILS_ENV').returns('development')
    profile.expects(:development_url_options).returns({ :port => 9999 })
    ok('Profile#url_options must include port option when running in development mode') { profile.url_options[:port] == 9999 }
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

  should 'have administator role' do
    Role.expects(:find_by_key).with('profile_admin').returns(Role.new)
    assert_kind_of Role, Profile::Roles.admin
  end

  should 'have member role' do
    Role.expects(:find_by_key).with('profile_member').returns(Role.new)
    assert_kind_of Role, Profile::Roles.member
  end

  should 'have moderator role' do
    Role.expects(:find_by_key).with('profile_moderator').returns(Role.new)
    assert_kind_of Role, Profile::Roles.moderator
  end

  should 'not have members by default' do
    assert_equal false, Profile.new.has_members?
  end

  should 'create a homepage and a feed on creation' do
    profile = Profile.create!(:name => 'my test profile', :identifier => 'mytestprofile')

    assert_kind_of Article, profile.home_page
    assert_kind_of RssFeed, profile.articles.find_by_path('feed')
  end

  should 'allow to add new members' do
    c = Profile.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    p = create_user('mytestuser').person

    c.add_member(p)

    assert c.members.include?(p), "Profile should add the new member"
  end

  should 'allow to add administrators' do
    c = Profile.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    p = create_user('mytestuser').person

    c.add_admin(p)

    assert c.members.include?(p), "Profile should add the new admin"
  end

  should 'have tasks' do
    c = Profile.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    t1 = c.tasks.build
    t1.save!

    t2 = c.tasks.build
    t2.save!

    assert_equal [t1, t2], c.tasks
  end

  should 'have pending tasks' do
    c = Profile.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    t1 = c.tasks.build; t1.save!
    t2 = c.tasks.build; t2.save!; t2.finish
    t3 = c.tasks.build; t3.save!

    assert_equal [t1, t3], c.tasks.pending
  end

  should 'have finished tasks' do
    c = Profile.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    t1 = c.tasks.build; t1.save!
    t2 = c.tasks.build; t2.save!; t2.finish
    t3 = c.tasks.build; t3.save!; t3.finish

    assert_equal [t2, t3], c.tasks.finished
  end

  should 'responds to categories' do
    c = Profile.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    assert_respond_to c, :categories
  end

  should 'have categories' do
    c = Profile.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    cat = Environment.default.categories.build(:name => 'a category'); cat.save!
    c.categories << cat
    c.save!
    assert_includes c.categories, cat
  end

  should 'be able to list recent profiles' do
    Profile.delete_all

    p1 = Profile.create!(:name => 'first test profile', :identifier => 'first')
    p2 = Profile.create!(:name => 'second test profile', :identifier => 'second')
    p3 = Profile.create!(:name => 'thirs test profile', :identifier => 'third')

    assert_equal [p3,p2,p1], Profile.recent
  end

  should 'be able to list recent profiles with limit' do
    Profile.delete_all

    p1 = Profile.create!(:name => 'first test profile', :identifier => 'first')
    p2 = Profile.create!(:name => 'second test profile', :identifier => 'second')
    p3 = Profile.create!(:name => 'thirs test profile', :identifier => 'third')

    assert_equal [p3,p2], Profile.recent(2)
  end

  should 'advertise false to homepage and feed on creation' do
    profile = Profile.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    assert !profile.home_page.advertise?
    assert !profile.articles.find_by_path('feed').advertise?
  end

  should 'advertise true to homepage after update' do
    profile = Profile.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    assert !profile.home_page.advertise?
    profile.home_page.name = 'Changed name'
    assert profile.home_page.save!
    assert profile.home_page.advertise?
  end

  should 'advertise true to feed after update' do
    profile = Profile.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    assert !profile.articles.find_by_path('feed').advertise?
    profile.articles.find_by_path('feed').name = 'Changed name'
    assert profile.articles.find_by_path('feed').save!
    assert profile.articles.find_by_path('feed').advertise?
  end

  should 'find by initial' do
    inside = Profile.create!(:name => 'A person', :identifier => 'aperson')
    outside = Profile.create!(:name => 'B Movie', :identifier => 'bmovie')

    list = Profile.find_by_initial('a')

    assert_includes list, inside
    assert_not_includes list, outside
  end

  should 'have latitude and longitude' do
    e = Enterprise.create!(:name => 'test1', :identifier => 'test1')
    e.lat, e.lng = 45, 45 ; e.save!

    assert_includes Enterprise.find_within(2, :origin => [45, 45]), e    
  end

  should 'have latitude and longitude and find' do
    e = Enterprise.create!(:name => 'test1', :identifier => 'test1')
    e.lat, e.lng = 45, 45 ; e.save!

    assert_includes Enterprise.find(:all, :within => 2, :origin => [45, 45]), e    
  end

  should 'allow to remove members' do
    c = Profile.create!(:name => 'my other test profile', :identifier => 'myothertestprofile')
    p = create_user('myothertestuser').person

    c.add_member(p)
    assert_includes c.members, p
    c.remove_member(p)
    c.reload
    assert_not_includes c.members, p
  end

  should 'have a public profile by default' do
    assert_equal true, Profile.new.public_profile
  end

  should 'be able to turn profile private' do
    p = Profile.new
    p.public_profile = false
    assert_equal false, p.public_profile
  end

  should 'have public content by default' do
    assert_equal true, Profile.new.public_content
  end

  should 'be able to turn content private' do
    p = Profile.new
    p.public_content = false
    assert_equal false, p.public_content
  end

  private

  def assert_invalid_identifier(id)
    profile = Profile.new(:identifier => id)
    assert !profile.valid?
    assert profile.errors.invalid?(:identifier)
  end

end
