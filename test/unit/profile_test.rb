require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < Test::Unit::TestCase
  fixtures :profiles, :environments, :users, :roles, :domains

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
    assert_equal Environment.default, create(Profile).environment
  end

  should 'not override environment informed before creation' do
    env = fast_create(Environment)
    p = create(Profile, :environment_id => env.id)

    assert_equal env, p.environment
  end

  should 'be able to set environment after instantiation and before creating' do
    env = fast_create(Environment)
    p = create(Profile)
    p.environment = env
    p.save!

    p.reload
    assert_equal env, p.environment
  end

  should 'set default environment for users created' do
    user = create_user 'mytestuser'
    assert_equal 'mytestuser', user.login
    assert !user.new_record?

    p = user.person

    assert !p.new_record?
    assert_equal 'mytestuser', p.identifier
    e = p.environment
    assert_equal Environment.default, e
  end

  should 'provide access to home page' do
    profile = create(Profile)
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
    pr = fast_create(Profile)
    pe = create_user('aff', :email => 'aff@pr.coop', :password => 'blih', :password_confirmation => 'blih').person

    member_role = Role.new(:name => 'new_member_role')
    assert member_role.save
    assert pr.affiliate(pe, member_role)

    assert pe.memberships.include?(pr)
  end

  def test_find_by_contents
    p = create(Profile, :name => 'wanted')

    assert Profile.find_by_contents('wanted').include?(p)
    assert ! Profile.find_by_contents('not_wanted').include?(p)
  end

  should 'remove pages when removing profile' do
    profile = fast_create(Profile)
    first = fast_create(Article, :profile_id => profile.id)
    second = fast_create(Article, :profile_id => profile.id)
    third = fast_create(Article, :profile_id => profile.id)

    total = Article.count
    mine = profile.articles.count
    profile.destroy
    assert_equal total - mine, Article.count
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
    assert_invalid_identifier 'root'
    assert_invalid_identifier 'assets'
  end

  should 'provide recent documents' do
    profile = fast_create(Profile)
    profile.articles.destroy_all

    first  = fast_create(Article, { :profile_id => profile.id }, :timestamps => true)
    second = fast_create(Article, { :profile_id => profile.id }, :timestamps => true)
    third  = fast_create(Article, { :profile_id => profile.id }, :timestamps => true)

    assert_equal [third, second], profile.recent_documents(2)
    assert_equal [third, second, first], profile.recent_documents
  end

  should 'affiliate and provide a list of the affiliated users' do
    profile = fast_create(Profile)
    person = create_user('test_user').person
    role = Role.create!(:name => 'just_another_test_role')
    assert profile.affiliate(person, role)
    assert profile.members.map(&:id).include?(person.id)
  end

  should 'authorize users that have permission on the environment' do
    env = fast_create(Environment)
    profile = fast_create(Profile, :environment_id => env.id)
    person = create_user('test_user').person
    role = Role.create!(:name => 'just_another_test_role', :permissions => ['edit_profile'])
    assert env.affiliate(person, role)
    assert person.has_permission?('edit_profile', profile)
  end

  should 'have articles' do
    profile = build(Profile)

    assert_raise ActiveRecord::AssociationTypeMismatch do
      profile.articles << 1
    end

    assert_nothing_raised do
      profile.articles << build(Article)
    end
  end

  should 'list top-level articles' do
    profile = fast_create(Profile)

    p1 = create(Article, :profile_id => profile.id)
    p2 = create(Article, :profile_id => profile.id)

    child = create(Article, :profile_id => profile.id, :parent_id => p1.id)

    top = profile.top_level_articles
    assert top.include?(p1)
    assert top.include?(p2)
    assert !top.include?(child)
  end

  should 'be able to optionally reload the list of top level articles' do
    profile = fast_create(Profile)

    list = profile.top_level_articles
    same_list = profile.top_level_articles
    assert_same list, same_list

    other_list = profile.top_level_articles(true)
    assert_not_same list, other_list
  end

  should 'be able to find profiles by their names with ferret' do
    small = create(Profile, :name => 'A small profile for testing')
    big = create(Profile, :name => 'A big profile for testing')

    assert Profile.find_by_contents('small').include?(small)
    assert Profile.find_by_contents('big').include?(big)

    both = Profile.find_by_contents('profile testing')
    assert both.include?(small)
    assert both.include?(big)
  end

  should 'provide a shortcut for picking a profile by its identifier' do
    profile = fast_create(Profile, :identifier => 'testprofile')
    assert_equal profile, Profile['testprofile']
  end

  should 'have boxes upon creation' do
    profile = create(Profile)
    assert profile.boxes.size > 0
  end

  should 'remove boxes and blocks when removing profile' do
    profile = Profile.create!(:name => 'test profile', :identifier => 'testprofile')
    profile.boxes.first.blocks << MainBlock.new

    profile_boxes = profile.boxes.size
    profile_blocks = profile.blocks(true).size

    assert profile_boxes > 0, 'profile should have some boxes'
    assert profile_blocks > 0, 'profile should have some blocks'

    boxes = Box.count
    blocks = Block.count

    profile.destroy

    assert_equal boxes - profile_boxes, Box.count
    assert_equal blocks - profile_blocks, Block.count
  end

  should 'provide url to itself' do
    environment = create_environment('mycolivre.net')
    profile = build(Profile, :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)

    assert_equal({ :host => 'mycolivre.net', :profile => 'testprofile', :controller => 'content_viewer', :action => 'view_page', :page => []}, profile.url)
  end

  should 'provide URL to admin area' do
    environment = create_environment('mycolivre.net')
    profile = build(Profile, :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)

    assert_equal({ :profile => 'testprofile', :controller => 'profile_editor', :action => 'index'}, profile.admin_url)
  end

  should 'provide URL to public profile' do
    environment = create_environment('mycolivre.net')
    profile = build(Profile, :identifier => 'testprofile', :environment_id => environment.id)

    assert_equal({ :host => 'mycolivre.net', :profile => 'testprofile', :controller => 'profile', :action => 'index' }, profile.public_profile_url)
  end

  should "use own domain name instead of environment's for home page url" do
    profile = build(Profile, :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)
    profile.domains << Domain.new(:name => 'micojones.net')

    assert_equal({:host => 'micojones.net', :profile => nil, :controller => 'content_viewer', :action => 'view_page', :page => []}, profile.url)
  end

  should 'help developers by adding a suitable port to url' do
    profile = build(Profile)

    Noosfero.expects(:url_options).returns({ :port => 9999 })

    assert profile.url[:port] == 9999, 'Profile#url_options must include port option when running in development mode'
  end

  should 'help developers by adding a suitable port to url options for own domain urls' do
    environment = create_environment('mycolivre.net')
    profile = build(Profile, :environment_id => environment.id)
    profile.domains << build(Domain)

    Noosfero.expects(:url_options).returns({ :port => 9999 })

    assert profile.url[:port] == 9999, 'Profile#url must include port options when running in developers mode'
  end

  should 'list article tags for profile' do
    profile = fast_create(Profile)
    create(Article, :profile => profile, :tag_list => 'first-tag')
    create(Article, :profile => profile, :tag_list => 'first-tag, second-tag')
    create(Article, :profile => profile, :tag_list => 'first-tag, second-tag, third-tag')

    assert_equal({ 'first-tag' => 3, 'second-tag' => 2, 'third-tag' => 1 }, profile.article_tags)
  end

  should 'list tags for profile' do
    profile = create(Profile, :tag_list => 'first-tag, second-tag')

    assert_equal(['first-tag', 'second-tag'], profile.tags.map(&:name))
  end

  should 'find content tagged with given tag' do
    profile = fast_create(Profile)
    first   = create(Article, :profile => profile, :tag_list => 'first-tag')
    second  = create(Article, :profile => profile, :tag_list => 'first-tag, second-tag')
    third   = create(Article, :profile => profile, :tag_list => 'first-tag, second-tag, third-tag')

    assert_equivalent [ first, second, third], profile.find_tagged_with('first-tag')
    assert_equivalent [ second, third ], profile.find_tagged_with('second-tag')
    assert_equivalent [ third], profile.find_tagged_with('third-tag')
  end

  should 'provide tag count' do
    assert_equal 0, Profile.new.tags.size
  end

  should 'have administator role' do
    Role.expects(:find_by_key_and_environment_id).with('profile_admin', Environment.default.id).returns(Role.new)
    assert_kind_of Role, Profile::Roles.admin(Environment.default.id)
  end

  should 'have member role' do
    Role.expects(:find_by_key_and_environment_id).with('profile_member', Environment.default.id).returns(Role.new)
    assert_kind_of Role, Profile::Roles.member(Environment.default.id)
  end

  should 'have moderator role' do
    Role.expects(:find_by_key_and_environment_id).with('profile_moderator', Environment.default.id).returns(Role.new)
    assert_kind_of Role, Profile::Roles.moderator(Environment.default.id)
  end

  should 'not have members by default' do
    assert_equal false, Profile.new.has_members?
  end

  should 'create a homepage and a feed on creation' do
    profile = create(Profile)

    assert_kind_of Article, profile.home_page
    assert_kind_of RssFeed, profile.articles.find_by_path('feed')
  end

  should 'not allow to add members' do
    c = fast_create(Profile)
    p = create_user('mytestuser').person
    assert_raise RuntimeError do
      c.add_member(p)
    end
  end

  should 'allow to add administrators' do
    c = fast_create(Profile)
    p = create_user('mytestuser').person

    c.add_admin(p)

    assert c.members.include?(p), "Profile should add the new admin"
  end

  should 'not allow to add moderators' do
    c = fast_create(Profile)
    p = create_user('mytestuser').person
    assert_raise RuntimeError do
      c.add_moderator(p)
    end
  end

  should 'have tasks' do
    c = fast_create(Profile)
    t1 = c.tasks.build
    t1.save!

    t2 = c.tasks.build
    t2.save!

    assert_equal [t1, t2], c.tasks
  end

  should 'have pending tasks' do
    c = fast_create(Profile)
    t1 = c.tasks.build; t1.save!
    t2 = c.tasks.build; t2.save!; t2.finish
    t3 = c.tasks.build; t3.save!

    assert_equal [t1, t3], c.tasks.pending
  end

  should 'have finished tasks' do
    c = fast_create(Profile)
    t1 = c.tasks.build; t1.save!
    t2 = c.tasks.build; t2.save!; t2.finish
    t3 = c.tasks.build; t3.save!; t3.finish

    assert_equal [t2, t3], c.tasks.finished
  end

  should 'responds to categories' do
    c = fast_create(Profile)
    assert_respond_to c, :categories
  end

  should 'have categories' do
    c = fast_create(Profile)
    cat = Environment.default.categories.build(:name => 'a category'); cat.save!
    c.add_category cat
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
    profile = create(Profile)
    assert !profile.home_page.advertise?
    assert !profile.articles.find_by_path('feed').advertise?
  end

  should 'advertise true to homepage after update' do
    profile = create(Profile)
    assert !profile.home_page.advertise?
    profile.home_page.name = 'Changed name'
    assert profile.home_page.save!
    assert profile.home_page.advertise?
  end

  should 'advertise true to feed after update' do
    profile = create(Profile)
    assert !profile.articles.find_by_path('feed').advertise?
    profile.articles.find_by_path('feed').name = 'Changed name'
    assert profile.articles.find_by_path('feed').save!
    assert profile.articles.find_by_path('feed').advertise?
  end

  should 'have latitude and longitude' do
    e = fast_create(Enterprise, :lat => 45, :lng => 45)

    assert_includes Enterprise.find_within(2, :origin => [45, 45]), e    
  end

  should 'have latitude and longitude and find' do
    e = fast_create(Enterprise, :lat => 45, :lng => 45)

    assert_includes Enterprise.find(:all, :within => 2, :origin => [45, 45]), e    
  end

  should 'have a public profile by default' do
    assert_equal true, Profile.new.public_profile
  end

  should 'be able to turn profile private' do
    p = Profile.new
    p.public_profile = false
    assert_equal false, p.public_profile
  end

  should 'be able to find the public profiles but not private ones' do
    p1 = create(Profile, :public_profile => true)
    p2 = create(Profile, :public_profile => false)

    result = Profile.find(:all, :conditions => {:public_profile => true})
    assert_includes result, p1
    assert_not_includes result, p2
  end

  should 'have public content by default' do
    assert_equal true, Profile.new.public_content
  end

  should 'be able to turn content private' do
    p = Profile.new
    p.public_content = false
    assert_equal false, p.public_content
  end

  should 'not display private profile to unauthenticated user' do
    assert !Profile.new(:public_profile => false).display_info_to?(nil)
  end

  should 'display private profile for its owner' do
    p = Profile.new(:public_profile => false)
    assert p.display_info_to?(p)
  end

  should 'display private profile for members' do
    p = fast_create(Person)
    c = fast_create(Community, :public_profile => false)
    c.expects(:closed).returns(false)
    c.add_member(p)
    assert c.display_info_to?(p)
  end

  should 'display profile for administrators' do
    p = create_user('testuser').person
    p.update_attribute('public_profile', false)
    admin = Person[create_admin_user(p.environment)]
    assert p.display_info_to?(admin)
  end

  should 'be able to add extra data for index' do
    klass = Class.new(Profile)
    klass.any_instance.expects(:random_method)
    klass.extra_data_for_index :random_method

    klass.new.extra_data_for_index
  end

  should 'be able to add a block as extra data for index' do
    klass = Class.new(Profile)
    result = Object.new
    klass.extra_data_for_index do |obj|
      result
    end

    assert_includes klass.new.extra_data_for_index, result
  end

  # TestingExtraDataForIndex is a subclass of profile that adds a block as
  # content to be added to the index. The block returns "sample indexed text"
  # see test/mocks/test/testing_extra_data_for_index.rb
  should 'actually index by results of extra_data_for_index' do
    profile = TestingExtraDataForIndex.create!(:name => 'testprofile', :identifier => 'testprofile')

    assert_includes TestingExtraDataForIndex.find_by_contents('sample'), profile
  end

  should 'index profile identifier for searching' do
    Profile.destroy_all
    p = create(Profile, :identifier => 'lalala')
    assert_includes Profile.find_by_contents('lalala'), p
  end

  should 'index profile name for searching' do
    p = create(Profile, :name => 'Interesting Profile')
    assert_includes Profile.find_by_contents('interesting'), p
  end

  should 'enabled by default on creation' do
    profile = fast_create(Profile)
    assert profile.enabled?
  end

  should 'categorize in the entire category hierarchy' do
    c1 = fast_create(Category)
    c2 = fast_create(Category, :parent_id => c1.id)
    c3 = fast_create(Category, :parent_id => c2.id) 

    profile = create_user('testuser').person
    profile.add_category(c3)


    assert_equal [c3], profile.categories(true)
    assert_equal [profile], c2.people(true)

    assert_includes c3.people(true), profile
    assert_includes c2.people(true), profile
    assert_includes c1.people(true), profile
  end

  should 'redefine the entire category set at once' do
    c1 = fast_create(Category)
    c2 = fast_create(Category, :parent_id => c1.id)
    c3 = fast_create(Category, :parent_id => c2.id)
    c4 = fast_create(Category, :parent_id => c1.id)
    profile = fast_create(Profile)

    profile.add_category(c4)

    profile.category_ids = [c2,c3].map(&:id)

    assert_equivalent [c2, c3], profile.categories(true)
  end

  should 'be able to create an profile already with categories' do
    c1 = create(Category)
    c2 = create(Category)

    profile = create(Profile, :category_ids => [c1.id, c2.id])

    assert_equivalent [c1, c2], profile.categories(true)
  end

  should 'be associated with a region' do
    region = fast_create(Region)
    profile = fast_create(Profile, :region_id => region.id)

    assert_equal region, profile.region
  end

  should 'categorized automatically in its region' do
    region = fast_create(Region)
    profile = create(Profile, :region => region)

    assert_equal [region], profile.categories(true)
  end

  should 'change categorization when changing region' do
    region = fast_create(Region)
    region2 = fast_create(Region)

    profile = fast_create(Profile, :region_id => region.id)

    profile.region = region2
    profile.save!

    assert_equal [region2], profile.categories(true)
  end

  should 'remove categorization when removing region' do
    region = fast_create(Region)
    profile = fast_create(Profile, :region_id => region.id)

    profile.region = nil
    profile.save!

    assert_equal [], profile.categories(true)
  end

  should 'not remove region, only dissasociate from it' do
    region = fast_create(Region)
    profile = fast_create(Profile, :region_id => region.id)

    profile.region = nil
    profile.save!

    assert_nothing_raised do
      Region.find(region.id)
    end
  end

  should 'be able to create with categories and region at the same time' do
    region = fast_create(Region)
    category = fast_create(Category)
    profile = create(Profile, :region => region, :category_ids => [category.id])

    assert_equivalent [region, category], profile.categories(true)
  end

  should 'be able to update categories and not get regions removed' do
    region = fast_create(Region)
    category = fast_create(Category)
    category2 = fast_create(Category)
    profile = create(Profile, :region => region, :category_ids => [category.id])

    profile.update_attributes!(:category_ids => [category2.id])

    assert_includes profile.categories(true), region
  end

  should 'be able to update region and not get categories removed' do
    region = fast_create(Region)
    region2 = fast_create(Region)
    category = fast_create(Category)
    profile = create(Profile, :region => region, :category_ids => [category.id])

    profile.update_attributes!(:region => region2)

    assert_includes profile.categories(true), category
  end

  should 'not accept product category as category' do
    assert !Profile.new.accept_category?(ProductCategory.new)
  end

  should 'not accept region as a category' do
    assert !Profile.new.accept_category?(Region.new)
  end

  should 'query region for location' do
    region = build(Region, :name => 'Some ackward region name')
    p = build(Profile, :region => region)
    assert_equal 'Some ackward region name', p.location
  end

  should 'query region hierarchy for location up to 2 levels' do
    country = build(Region, :name => "Brazil")
    state   = build(Region, :name => "Bahia", :parent => country)
    city    = build(Region, :name => "Salvador", :parent => state)
    p       = build(Profile, :region => city)
    assert_equal 'Salvador - Bahia', p.location
  end

  should 'use city/state/country/address/zip_code fields for location when no region object is set' do
    p = Profile.new
    p.expects(:region).returns(nil)
    p.expects(:address).returns("Rua A").at_least_once
    p.expects(:city).returns("Salvador").at_least_once
    p.expects(:state).returns("Bahia").at_least_once
    p.expects(:country_name).returns("Brasil").at_least_once
    p.expects(:zip_code).returns("40000000").at_least_once
    assert_equal 'Rua A - Salvador - Bahia - Brasil - 40000000', p.location
  end

  should 'choose separator for location' do
    p = Profile.new
    p.expects(:region).returns(nil)
    p.expects(:address).returns("Rua A").at_least_once
    p.expects(:city).returns("Salvador").at_least_once
    p.expects(:state).returns("Bahia").at_least_once
    p.expects(:country_name).returns("Brasil").at_least_once
    p.expects(:zip_code).returns("40000000").at_least_once
    assert_equal 'Rua A, Salvador, Bahia, Brasil, 40000000', p.location(', ')
  end

  should 'not display separator on location if city/state/country/address/zip_code is blank' do
    p = Profile.new
    p.expects(:region).returns(nil)
    p.expects(:address).returns("Rua A").at_least_once
    p.expects(:city).returns("Salvador").at_least_once
    p.expects(:state).returns("").at_least_once
    p.expects(:country_name).returns("Brasil").at_least_once
    p.expects(:zip_code).returns("40000000").at_least_once
    assert_equal 'Rua A - Salvador - Brasil - 40000000', p.location
  end

  should 'use location on geolocation if not blank' do
    p = Profile.new
    p.expects(:region).returns(nil).at_least_once
    p.expects(:address).returns("Rua A").at_least_once
    p.expects(:city).returns("Salvador").at_least_once
    p.expects(:state).returns("").at_least_once
    p.expects(:country_name).returns("Brasil").at_least_once
    p.expects(:zip_code).returns("40000000").at_least_once
    assert_equal 'Rua A - Salvador - Brasil - 40000000', p.geolocation
  end

  should 'use default location on geolocation if not blank' do
    p = Profile.new
    p.expects(:region).returns(nil)
    e = Environment.default
    p.stubs(:environment).returns(e)
    e.stubs(:location).returns('Brasil')
    assert_equal 'Brasil', p.geolocation
  end


  should 'lookup country name' do
    p = Profile.new
    # two sample countries; trust the rest works
    p.stubs(:country).returns('BR')
    assert_equal 'Brazil', p.country_name
    p.stubs(:country).returns('AR')
    assert_equal 'Argentina', p.country_name
  end

  should 'give empty location if nothing is available' do
    p = Profile.new
    p.expects(:region).returns(nil)
    assert_equal '', p.location
  end

  should 'support (or at least not crash) location for existing profile types' do
    assert_nothing_raised do
      [Profile,Enterprise,Person,Community,Organization].each { |p| p.new.location }
    end
  end

  should 'default home page is a TinyMceArticle' do
    profile = create(Profile)
    assert_kind_of TinyMceArticle, profile.home_page
  end

  should 'not add a category twice to profile' do
    c1 = fast_create(Category)
    c2 = fast_create(Category, :parent_id => c1.id)
    c3 = fast_create(Category, :parent_id => c1.id)
    profile = fast_create(Profile)
    profile.category_ids = [c2,c3,c3].map(&:id)
    assert_equal [c2, c3], profile.categories(true)
  end

  should 'not return nil members when a member is removed from system' do
    p = fast_create(Community)
    member = create_user('test_user').person
    p.add_member(member)

    member.destroy
    p.reload

    assert_not_includes p.members, nil
  end

  should 'have nickname' do
    p = Profile.new
    assert_respond_to p, :nickname
  end

  should 'nickname has limit of 16 characters' do
    p = Profile.new(:nickname => 'A name with more then 16 characters')
    p.valid?
    assert_not_nil p.errors[:nickname]
  end

  should 'nickname be able to be nil' do
    p = Profile.new()
    p.valid?
    assert_nil p.errors[:nickname]
  end

  should 'filter html from nickname' do
    p = Profile.create!(:identifier => 'testprofile', :name => 'test profile', :environment => Environment.default)
    p.nickname = "<b>code</b>"
    p.save!
    assert_equal 'code', p.nickname
  end

  should 'return truncated name in short_name if nickname is blank' do
    p = Profile.new(:name => 'a123456789abcdefghij')
    assert_equal 'a123456789ab...', p.short_name
  end

  should 'provide custom header' do
    assert_equal 'my custom header',  Profile.new(:custom_header => 'my custom header').custom_header
  end

  should 'provide custom header with variables' do
    assert_equal 'Custom header of {name}',  Profile.new(:custom_header => 'Custom header of {name}', :name => 'Test').custom_header
    assert_equal 'Custom header of Test',  Profile.new(:custom_header => 'Custom header of {name}', :name => 'Test').custom_header_expanded
  end

  should 'provide custom header with nickname when use short_name variable' do
    profile = Profile.new(:custom_header => 'Custom header of {short_name}', :name => 'Test', :nickname => 'Nickname test')
    assert_equal 'Custom header of {short_name}', profile.custom_header
    assert_equal 'Custom header of Nickname test',  profile.custom_header_expanded
  end

  should 'provide custom header with name when use short_name variable and no nickname' do
    profile = Profile.new(:custom_header => 'Custom header of {short_name}', :name => 'Test')
    assert_equal 'Custom header of {short_name}', profile.custom_header
    assert_equal 'Custom header of Test', profile.custom_header_expanded
  end

  should 'provide custom footer' do
    assert_equal 'my custom footer',  Profile.new(:custom_footer => 'my custom footer').custom_footer
  end

  should 'not replace variables on custom_footer if hasnt pattern' do
    assert_equal 'address}',  Profile.new(:custom_footer => 'address}', :address => 'Address for test').custom_footer
  end

  should 'replace variables on custom_footer' do
    assert_equal '{address}',  Profile.new(:custom_footer => '{address}', :address => 'Address for test').custom_footer
    assert_equal 'Address for test',  Profile.new(:custom_footer => '{address}', :address => 'Address for test').custom_footer_expanded
  end

  should 'replace variables on custom_footer with title' do
    assert_equal '{Address: address}',  Profile.new(:custom_footer => '{Address: address}', :address => 'Address for test').custom_footer
    assert_equal 'Address: Address for test',  Profile.new(:custom_footer => '{Address: address}', :address => 'Address for test').custom_footer_expanded
  end

  should 'replace variables on custom_footer when it is nil' do
    assert_equal '{address}',  Profile.new(:custom_footer => '{address}').custom_footer
    assert_equal '',  Profile.new(:custom_footer => '{address}').custom_footer_expanded
  end

  should 'replace variables on custom_footer when it is blank' do
    assert_equal '{ZIP Code: zip_code}',  Enterprise.new(:custom_footer => '{ZIP Code: zip_code}', :zip_code => '').custom_footer
    assert_equal '',  Enterprise.new(:custom_footer => '{ZIP Code: zip_code}', :zip_code => '').custom_footer_expanded
  end

  should 'replace variables in custom_footer when more than one' do
    assert_equal '{Address: address}{Phone: contact_phone}',  Profile.new(:custom_footer => '{Address: address}{Phone: contact_phone}', :contact_phone => '9999999').custom_footer
    assert_equal 'Phone: 9999999',  Profile.new(:custom_footer => '{Address: address}{Phone: contact_phone}', :contact_phone => '9999999').custom_footer_expanded
  end

  should 'replace variables on custom_footer with title when it is nil' do
    assert_equal '{Address: address}',  Profile.new(:custom_footer => '{Address: address}').custom_footer
    assert_equal '',  Profile.new(:custom_footer => '{Address: address}').custom_footer_expanded
  end

  should 'provide environment header if profile header is blank' do
    profile = Profile.new
    env = mock
    env.expects(:custom_header).returns('environment header')
    profile.stubs(:environment).returns(env)

    assert_equal 'environment header', profile.custom_header
  end

  should 'provide environment footer if profile footer is blank' do
    profile = Profile.new
    env = mock
    env.expects(:custom_footer).returns('environment footer')
    profile.stubs(:environment).returns(env)

    assert_equal 'environment footer', profile.custom_footer
  end

  should 'store theme' do
    p = Profile.new(:theme => 'my-shiny-theme')
    assert_equal 'my-shiny-theme', p.theme
  end

  should 'respond to public? as public_profile' do
    p1 = fast_create(Profile)
    p2 = fast_create(Profile, :public_profile => false)

    assert p1.public?
    assert !p2.public?
  end

  should 'create a initial private folder when a public profile is created' do
    p1 = create(Profile)
    p2 = create(Profile, :public_profile => false)

    assert p1.articles.find(:first, :conditions => {:published => false})
    assert !p2.articles.find(:first, :conditions => {:published => false})
  end

  should 'remove member with many roles' do
    person = create_user('test_user').person
    community = fast_create(Community)
    community.affiliate(person, Profile::Roles.all_roles(community.environment.id))

    community.remove_member(person)

    assert_not_includes person.memberships, community
  end

  should 'copy set of articles from a template' do
    template = create_user('test_template').person
    template.articles.destroy_all
    a1 = fast_create(Article, :profile_id => template.id, :name => 'some xyz article')
    a2 = fast_create(Article, :profile_id => template.id, :name => 'some child article', :parent_id => a1.id)

    Profile.any_instance.stubs(:template).returns(template)

    p = create(Profile)

    assert_equal 1, p.top_level_articles.size
    top_art = p.top_level_articles[0]
    assert_equal 'some xyz article', top_art.name
    assert_equal 1, top_art.children.size
    child_art = top_art.children[0]
    assert_equal 'some child article', child_art.name
  end

  should 'copy homepage from template' do
    template = create_user('test_template').person
    template.articles.destroy_all
    a1 = fast_create(Article, :profile_id => template.id, :name => 'some xyz article')
    template.home_page = a1
    template.save!

    Profile.any_instance.stubs(:template).returns(template)

    p = create(Profile)

    assert_not_nil p.home_page
    assert_equal 'some xyz article', p.home_page.name
  end

  should 'not advertise the articles copied from templates' do
    template = create_user('test_template').person
    template.articles.destroy_all
    a = fast_create(Article, :profile_id => template.id, :name => 'some xyz article')

    Profile.any_instance.stubs(:template).returns(template)

    p = create(Profile)

    a_copy = p.articles[0]

    assert !a_copy.advertise
  end
  
  should 'copy set of boxes from profile template' do
    template = fast_create(Profile)
    template.boxes.destroy_all
    template.boxes << Box.new
    template.boxes[0].blocks << Block.new
    template.save!

    Profile.any_instance.stubs(:template).returns(template)

    p = create(Profile)

    assert_equal 1, p.boxes.size
    assert_equal 1, p.boxes[0].blocks.size
  end

  should 'copy layout template when applying template' do
    template = fast_create(Profile)
    template.layout_template = 'leftbar'
    template.save!

    p = create(Profile)

    p.apply_template(template)

    assert_equal 'leftbar', p.layout_template
  end

  should 'copy blocks when applying template' do
    template = fast_create(Profile)
    template.boxes.destroy_all
    template.boxes << Box.new
    template.boxes[0].blocks << Block.new
    template.save!

    p = Profile.create!(:name => 'test prof', :identifier => 'test_prof')

    p.apply_template(template)

    assert_equal 1, p.boxes.size
    assert_equal 1, p.boxes[0].blocks.size
  end

  should 'copy articles when applying template' do
    template = fast_create(Profile)
    template.articles.create(:name => 'template article')
    template.save!

    p = Profile.create!(:name => 'test prof', :identifier => 'test_prof')

    p.apply_template(template)

    assert_not_nil p.articles.find_by_name('template article')
  end

  should 'rename existing articles when applying template' do
    template = fast_create(Profile)
    template.boxes.destroy_all
    template.boxes << Box.new
    template.boxes[0].blocks << Block.new
    template.articles.create(:name => 'some article')
    template.save!

    p = create(Profile)
    p.articles.create(:name => 'some article')

    p.apply_template(template)

    assert_not_nil p.articles.find_by_name('some article 2')
    assert_not_nil p.articles.find_by_name('some article')
  end

  should 'copy header when applying template' do
    template = fast_create(Profile)
    template[:custom_header] = '{name}' 
    template.save!

    p = create(Profile, :name => 'test prof')

    p.apply_template(template)

    assert_equal '{name}', p[:custom_header]
    assert_equal '{name}', p.custom_header
    assert_equal 'test prof', p.custom_header_expanded
  end

  should 'copy footer when applying template' do
    template = create(Profile, :address => 'Template address', :custom_footer => '{address}')

    p = create(Profile, :address => 'Profile address')
    p.apply_template(template)

    assert_equal '{address}', p[:custom_footer]
    assert_equal '{address}', p.custom_footer
    assert_equal 'Profile address', p.custom_footer_expanded
  end

  should 'ignore failing validation when applying template' do
    template = create(Profile, :layout_template => 'leftbar', :custom_footer => 'my custom footer', :custom_header => 'my custom header')

    p = create(Profile)
    def p.validate
      self.errors.add('identifier', 'is invalid')
    end

    p.apply_template(template)

    p.reload
    assert_equal 'leftbar', p.layout_template
    assert_equal 'my custom footer', p.custom_footer
    assert_equal 'my custom header', p.custom_header
  end

  should 'copy homepage when applying template' do
    template = fast_create(Profile)
    a1 = fast_create(Article, :profile_id => template.id, :name => 'some xyz article')
    template.home_page = a1
    template.save!

    p = fast_create(Profile)
    p.apply_template(template)

    assert_not_nil p.home_page
    assert_equal 'some xyz article', p.home_page.name
  end

  should 'not copy blocks default_title when applying template' do
    template = fast_create(Profile)
    template.boxes.destroy_all
    template.boxes << Box.new
    b = Block.new()
    template.boxes[0].blocks << b

    p = create(Profile)
    assert b[:title].blank?

    p.copy_blocks_from(template)

    assert_nil p.boxes[0].blocks.first[:title]
  end

  should 'copy blocks title when applying template' do
    template = fast_create(Profile)
    template.boxes.destroy_all
    template.boxes << Box.new
    b = Block.new(:title => 'default title')
    template.boxes[0].blocks << b

    p = create(Profile)
    assert !b[:title].blank?

    p.copy_blocks_from(template)

    assert_equal 'default title', p.boxes[0].blocks.first[:title]
  end

  TMP_THEMES_DIR = RAILS_ROOT + '/test/tmp/profile_themes'
  should 'have themes' do
    Theme.stubs(:user_themes_dir).returns(TMP_THEMES_DIR)

    begin
      p1 = fast_create(Profile)
      t = Theme.new('test_theme'); t.owner = p1; t.save

      assert_equal  [t], p1.themes
    ensure
      FileUtils.rm_rf(TMP_THEMES_DIR)
    end
  end

  should 'find theme by id' do
    Theme.stubs(:user_themes_dir).returns(TMP_THEMES_DIR)

    begin
      p1 = fast_create(Profile)
      t = Theme.new('test_theme'); t.owner = p1; t.save

      assert_equal  t, p1.find_theme('test_theme')
    ensure
      FileUtils.rm_rf(TMP_THEMES_DIR)
    end
  end

  should 'have a layout template' do
    p = Profile.new
    assert_equal 'default', p.layout_template
  end

  should 'get boxes limit from template' do
    p = create(Profile)

    layout = mock
    layout.expects(:number_of_boxes).returns(6)

    p.expects(:layout_template).returns('mylayout')
    LayoutTemplate.expects(:find).with('mylayout').returns(layout)

    assert_equal 6, p.boxes_limit
  end

  should 'copy public/private setting from template' do
    template = fast_create(Profile, :public_profile => false)
    p = fast_create(Profile)
    p.apply_template(template)
    assert_equal false, p.public_profile
  end

  should 'destroy tasks requested to it when destroyed' do
    p = Profile.create!(:name => 'test_profile', :identifier => 'test_profile')

    assert_no_difference Task, :count do
      Task.create(:target => p)
      p.destroy
    end
  end

  should 'not be possible to have different profiles with the same identifier in the same environment' do
    env = fast_create(Environment)

    p1 = fast_create(Profile, :identifier => 'mytestprofile', :environment_id => env.id)

    p2 = Profile.new(:identifier => 'mytestprofile', :environment => env)
    assert !p2.valid?

    assert p2.errors.on(:identifier)
    assert_equal p1.environment, p2.environment
  end

  should 'be possible to have different profiles with the same identifier in different environments' do
    p1 = fast_create(Profile, :identifier => 'mytestprofile')

    env = fast_create(Environment)
    p2 = create(Profile, :identifier => 'mytestprofile', :environment => env)

    assert_not_equal p1.environment, p2.environment
  end

  should 'has blog' do
    p = fast_create(Profile)
    p.articles << Blog.new(:profile => p, :name => 'blog_feed_test')
    assert p.has_blog?
  end

  should 'not has blog' do
    p = fast_create(Profile)
    assert !p.has_blog?
  end

  should 'get nil when no blog' do
    p = fast_create(Profile)
    assert_nil p.blog
  end

  should 'list admins' do
    c = fast_create(Profile)
    p = create_user('mytestuser').person
    c.add_admin(p)

    assert_equal [p], c.admins
  end

  should 'not implement contact_email' do
    assert_raise NotImplementedError do
      Profile.new.contact_email
    end
  end

  should 'delegate to contact_email to retrieve notification e-mails' do
    p = Profile.new
    p.stubs(:contact_email).returns('my@email.com')
    assert_equal ['my@email.com'], p.notification_emails
  end

  should 'enable contact for person only if its features enabled in environment' do
    env = Environment.default
    env.disable('disable_contact_person')
    person = Person.new(:name => 'Contacted', :environment => env)
    assert person.enable_contact?
  end

  should 'enable contact for community only if its features enabled in environment' do
    env = Environment.default
    env.disable('disable_contact_person')
    community = Community.new(:name => 'Contacted', :environment => env)
    assert community.enable_contact?
  end

  should 'include pending tasks from environment if is admin' do
    env = Environment.default
    person = create_user('molly').person
    task = Task.create!(:requestor => person, :target => env)

    Person.any_instance.stubs(:is_admin?).returns(true)
    assert_equal [task], person.all_pending_tasks
  end

  should 'find task from environment if is admin' do
    env = Environment.default
    person = create_user('molly').person
    task = Task.create!(:requestor => person, :target => env)

    Person.any_instance.stubs(:is_admin?).returns(true)
    assert_equal task, person.find_in_all_tasks(task.id)
  end

  should 'find task from all environment if is admin' do
    env = Environment.default
    another = fast_create(Environment)
    person = Person['ze']
    task1 = Task.create!(:requestor => person, :target => env)
    task2 = Task.create!(:requestor => person, :target => another)

    another.affiliate(person, Environment::Roles.admin(another.id))
    env.affiliate(person, Environment::Roles.admin(env.id))

    Person.any_instance.stubs(:is_admin?).returns(true)

    assert_equal [task1, task2], person.all_pending_tasks
  end

  should 'find task by id on all environments' do
    other   = fast_create(Environment)
    another = fast_create(Environment)
    person  = Person['ze']

    task1 = Task.create!(:requestor => person, :target => other)
    task2 = Task.create!(:requestor => person, :target => another)

    person.stubs(:is_admin?).with(other).returns(true)
    Environment.find(:all).select{|i| i != other }.each do |env| 
      person.stubs(:is_admin?).with(env).returns(false)
    end

    assert_not_nil person.find_in_all_tasks(task1.id)
    assert_nil person.find_in_all_tasks(task2.id)
  end

  should 'use environment hostname by default' do
    profile = Profile.new
    env = mock
    env.stubs(:default_hostname).returns('myenvironment.net')
    profile.stubs(:environment).returns(env)
    assert_equal 'myenvironment.net', profile.default_hostname
  end

  should 'use its first domain hostname name if available' do
    profile = fast_create(Profile)
    profile.domains << Domain.new(:name => 'myowndomain.net')
    assert_equal 'myowndomain.net', profile.default_hostname
  end

  should 'have a preferred domain name' do
    profile = fast_create(Profile)
    domain = create(Domain, :owner => profile)
    profile.preferred_domain = domain
    profile.save!

    assert_equal domain, Profile.find(profile.id).preferred_domain(true)
  end

  should 'use preferred domain for hostname' do
    profile = Profile.new(:identifier => 'myself')
    profile.stubs(:preferred_domain).returns(Domain.new(:name => 'preferred.net'))
    assert_equal 'preferred.net', profile.url[:host]
    assert_equal 'myself', profile.url[:profile]
  end

  should 'provide a list of possible preferred domain names' do
    profile = fast_create(Profile)
    domain1 = create(Domain, :owner => profile.environment)
    domain2 = create(Domain, :owner => profile)

    assert_includes profile.possible_domains, domain1
    assert_includes profile.possible_domains, domain2
  end

  should 'list folder articles' do
    profile = fast_create(Profile)
    Article.destroy_all
    p1 = Folder.create!(:name => 'parent1', :profile => profile)
    p2 = Blog.create!(:name => 'parent2', :profile => profile)

    assert p1.folder?
    assert p2.folder?

    child = profile.articles.create!(:name => 'child', :parent => p1)
    profile.reload
    assert_equivalent [p1, p2], profile.folders
    assert !profile.folders.include?(child)
  end

  should 'validates profile image when save' do
    profile = build(Profile, :image_builder => {:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')})
    profile.image.expects(:valid?).returns(false).at_least_once
    assert !profile.valid?
  end

  should 'profile is invalid when image not valid' do
    profile = build(Profile, :image_builder => {:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')})
    profile.image.expects(:valid?).returns(false).at_least_once
    profile.image.errors.add(:size, "fake error")
    assert !profile.valid?
  end

  should 'profile be valid when image is empty' do
    profile = Profile.new(:image_builder => {:uploaded_data => ""})
    profile.valid?
    assert_nil profile.errors[:image]
  end

  should 'profile be valid when has no image' do
    profile = Profile.new
    profile.valid?
    assert_nil profile.errors[:image]
  end

  should 'copy header and footer after create a person' do
    template = fast_create(Profile)
    template.custom_footer = "footer customized"
    template.custom_header = "header customized"
    Environment.any_instance.stubs(:person_template).returns(template)

    person = create_user_full('mytestuser').person
    assert_equal "footer customized", person.custom_footer
    assert_equal "header customized", person.custom_header
  end

  should 'provide URL to leave' do
    profile = build(Profile, :identifier => 'testprofile')
    assert_equal({ :profile => 'testprofile', :controller => 'profile', :action => 'leave'}, profile.leave_url)
  end

  should 'provide URL to join' do
    profile = build(Profile, :identifier => 'testprofile')
    assert_equal({ :profile => 'testprofile', :controller => 'profile', :action => 'join'}, profile.join_url)
  end

  should 'ignore category with id zero' do
    profile = fast_create(Profile)
    c = fast_create(Category)
    profile.category_ids = ['0', c.id, nil]

    assert_equal [c], profile.categories
  end

  should 'get first blog when has multiple blogs' do
    p = fast_create(Profile)
    p.blogs << Blog.new(:profile => p, :name => 'Blog one')
    p.blogs << Blog.new(:profile => p, :name => 'Blog two')
    p.blogs << Blog.new(:profile => p, :name => 'Blog three')
    assert_equal 'Blog one', p.blog.name
    assert_equal 3, p.blogs.count
  end

  should 'list all events' do
    profile = fast_create(Profile)
    event1 = Event.new(:name => 'Ze Birthday', :start_date => Date.today)
    event2 = Event.new(:name => 'Mane Birthday', :start_date => Date.today >> 1)
    profile.events << [event1, event2]
    assert_includes profile.events, event1
    assert_includes profile.events, event2
  end

  should 'list events by day' do
    profile = fast_create(Profile)

    today = Date.today
    yesterday_event = Event.new(:name => 'Joao Birthday', :start_date => today - 1.day)
    today_event = Event.new(:name => 'Ze Birthday', :start_date => today)
    tomorrow_event = Event.new(:name => 'Mane Birthday', :start_date => today + 1.day)

    profile.events << [yesterday_event, today_event, tomorrow_event]

    assert_equal [today_event], profile.events.by_day(today)
  end

  should 'list events in a range' do
    profile = fast_create(Profile)

    today = Date.today
    event_in_range = Event.new(:name => 'Noosfero Conference', :start_date => today - 2.day, :end_date => today + 2.day)
    event_in_day = Event.new(:name => 'Ze Birthday', :start_date => today)

    profile.events << [event_in_range, event_in_day]

    assert_equal [event_in_range], profile.events.by_day(today - 1.day)
    assert_equal [event_in_range], profile.events.by_day(today + 1.day)
    assert_equal [event_in_range, event_in_day], profile.events.by_day(today)
  end

  should 'not list events out of range' do
    profile = fast_create(Profile)

    today = Date.today
    event_in_range1 = Event.new(:name => 'Foswiki Conference', :start_date => today - 2.day, :end_date => today + 2.day)
    event_in_range2 = Event.new(:name => 'Debian Conference', :start_date => today - 2.day, :end_date => today + 3.day)
    event_out_of_range = Event.new(:name => 'Ze Birthday', :start_date => today - 5.day, :end_date => today - 3.day)

    profile.events << [event_in_range1, event_in_range2, event_out_of_range]

    assert_includes profile.events.by_day(today), event_in_range1
    assert_includes profile.events.by_day(today), event_in_range2
    assert_not_includes profile.events.by_day(today), event_out_of_range
  end

  should 'sort events by name' do
    profile = fast_create(Profile)
    event1 = Event.new(:name => 'Noosfero Hackaton', :start_date => Date.today)
    event2 = Event.new(:name => 'Debian Day', :start_date => Date.today)
    event3 = Event.new(:name => 'Fisl 10', :start_date => Date.today)
    profile.events << [event1, event2, event3]
    assert_equal [event2, event3, event1], profile.events
  end

  should 'be available if identifier doesnt exist on environment' do
    p = fast_create(Profile, :identifier => 'identifier-test')
    env = fast_create(Environment)
    assert_equal true, Profile.is_available?('identifier-test', env)
  end

  should 'not be available if identifier exists on environment' do
    p = create_user('identifier-test').person
    p = fast_create(Profile, :identifier => 'identifier-test')
    assert_equal false, Profile.is_available?('identifier-test', Environment.default)
  end

  should 'not have long descriptions' do
    long_description = 'a' * 600
    profile = Profile.new
    profile.description = long_description
    profile.valid?
    assert profile.errors.invalid?(:description)
  end

  private

  def assert_invalid_identifier(id)
    profile = Profile.new(:identifier => id)
    assert !profile.valid?
    assert profile.errors.invalid?(:identifier)
  end
end
