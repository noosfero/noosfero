require File.dirname(__FILE__) + '/../test_helper'
require 'browse_controller'

# Re-raise errors caught by the controller.
class BrowseController; def rescue_action(e) raise e end; end

class BrowseControllerTest < Test::Unit::TestCase

  def setup
    @controller = BrowseController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(false)
    @response   = ActionController::TestResponse.new

    # By pass user validation on person creation
    user = mock()
    user.stubs(:id).returns(1)
    user.stubs(:valid?).returns(true)
    user.stubs(:email).returns('some@test.com')
    user.stubs(:save!).returns(true)
    Person.any_instance.stubs(:user).returns(user)
    @profile = create_user('testinguser').person
    Article.destroy_all
  end
  attr_reader :profile

  should 'search for people' do
    Person.delete_all
    small = create(Person, :name => 'A small person for testing', :user_id => 1)
    create(Person, :name => 'A big person for testing', :user_id => 2)

    get :people, :query => 'small'
    assert_equal [small], assigns(:results)
  end

  should 'list all people order by more recent one by default' do
    Person.delete_all
    p1 = create(Person, :name => 'Testing person 1', :user_id => 1, :created_at => DateTime.now - 2)
    p2 = create(Person, :name => 'Testing person 2', :user_id => 2, :created_at => DateTime.now - 1)
    p3 = create(Person, :name => 'Testing person 3', :user_id => 3)

    get :people
    assert_equal [p3,p2,p1] , assigns(:results)
  end

  should 'paginate search of people in groups of 27' do
    Person.delete_all

    1.upto(30).map do |n|
      create(Person, :name => 'Testing person', :user_id => n)
    end

    get :people
    assert_equal 30 , Person.count
    assert_equal 27 , assigns(:results).count
    assert_tag :a, '', :attributes => {:class => 'next_page'}
  end

  should 'paginate ferret search of people in groups of 27' do
    Person.delete_all

    1.upto(30).map do |n|
      create(Person, :name => 'Testing person', :user_id => n)
    end

    get :people, :query => 'Testing'
    assert_equal 27 , assigns(:results).count
    assert_tag :a, '', :attributes => {:class => 'next_page'}
  end

  should 'not return nil results in the more_active people list' do
    Profile.delete_all
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    fast_create(Article, :profile_id => p1, :created_at => 1.day.ago)
    fast_create(Article, :profile_id => p2, :created_at => 1.day.ago)
    fast_create(Article, :profile_id => p2, :created_at => 1.day.ago)
    fast_create(Article, :profile_id => p2, :created_at => 1.day.ago)
    fast_create(Article, :profile_id => p3, :created_at => 1.day.ago)

    per_page = 1
    @controller.stubs(:per_page).returns(per_page)

    get :people, :filter => 'more_active'

    assert_equal Person.count/per_page, assigns(:results).total_pages
  end

  should 'list all people filter by more active' do
    Person.delete_all
    p1 = create(Person, :name => 'Testing person 1', :user_id => 1)
    p2 = create(Person, :name => 'Testing person 2', :user_id => 2)
    p3 = create(Person, :name => 'Testing person 3', :user_id => 3)
    ActionTracker::Record.delete_all
    fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => p1, :created_at => Time.now)
    fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => p2, :created_at => Time.now)
    fast_create(ActionTracker::Record, :user_type => 'Profile', :user_id => p2, :created_at => Time.now)
    get :people, :filter => 'more_active'
    assert_equal [p2,p1,p3] , assigns(:results)
  end

  should 'filter more popular people' do
    Person.delete_all
    p1 = create(Person, :name => 'Testing person 1', :user_id => 1)
    p2 = create(Person, :name => 'Testing person 2', :user_id => 2)
    p3 = create(Person, :name => 'Testing person 3', :user_id => 3)

    p1.add_friend(p2)
    p2.add_friend(p1)
    p2.add_friend(p3)
    get :people, :filter => 'more_popular'
    assert_equal [p2,p1,p3] , assigns(:results)
  end

  should 'the people filter be only the hardcoded one' do
    get :people, :filter => 'more_recent'
    assert_equal 'more_recent' , assigns(:filter)

    get :people, :filter => 'more_active'
    assert_equal 'more_active' , assigns(:filter)

    get :people, :filter => 'more_popular'
    assert_equal 'more_popular' , assigns(:filter)

    get :people, :filter => 'more_anything'
    assert_equal 'more_recent' , assigns(:filter)
  end

  should 'the people filter define the title' do
    get :people, :filter => 'more_recent'
    assert_equal 'More recent people' , assigns(:title)
    assert_tag :h1, :content => 'More recent people'

    get :people, :filter => 'more_active'
    assert_equal 'More active people' , assigns(:title)
    assert_tag :h1, :content => 'More active people'

    get :people, :filter => 'more_popular'
    assert_equal 'More popular people' , assigns(:title)
    assert_tag :h1, :content => 'More popular people'

    get :people, :filter => 'more_anything'
    assert_equal 'More recent people' , assigns(:title)
    assert_tag :h1, :content => 'More recent people'
  end

  should 'search for community' do
    small = create(Community, :name => 'A small community for testing')
    create(Community, :name => 'A big community for testing')

    get :communities, :query => 'small'
    assert_equal [small], assigns(:results)
  end

  should 'list all community order by more recent one by default' do
    c1 = create(Community, :name => 'Testing community 1', :created_at => DateTime.now - 2)
    c2 = create(Community, :name => 'Testing community 2', :created_at => DateTime.now - 1)
    c3 = create(Community, :name => 'Testing community 3')

    get :communities
    assert_equal [c3,c2,c1] , assigns(:results)
  end

  should 'paginate search of communities in groups of 27' do
    1.upto(30).map do |n|
      create(Community, :name => 'Testing community')
    end

    get :communities
    assert_equal 30 , Community.count
    assert_equal 27 , assigns(:results).count
    assert_tag :a, '', :attributes => {:class => 'next_page'}
  end

  should 'paginate ferret search of communities in groups of 27' do
    1.upto(30).map do |n|
      create(Community, :name => 'Testing community')
    end

    get :communities, :query => 'Testing'
    assert_equal 27 , assigns(:results).count
    assert_tag :a, '', :attributes => {:class => 'next_page'}
  end

  should 'not return nil results in the more_active communities list' do
    Profile.delete_all
    c1 = fast_create(Community)
    c2 = fast_create(Community)
    c3 = fast_create(Community)
    fast_create(Article, :profile_id => c1, :created_at => 1.day.ago)
    fast_create(Article, :profile_id => c2, :created_at => 1.day.ago)
    fast_create(Article, :profile_id => c2, :created_at => 1.day.ago)
    fast_create(Article, :profile_id => c2, :created_at => 1.day.ago)
    fast_create(Article, :profile_id => c3, :created_at => 1.day.ago)

    per_page = 1
    @controller.stubs(:per_page).returns(per_page)

    get :communities, :filter => 'more_active'

    assert_equal Community.count/per_page, assigns(:results).total_pages
  end


  should 'list all communities filter by more active' do
    person = fast_create(Person)
    c1 = create(Community, :name => 'Testing community 1')
    c2 = create(Community, :name => 'Testing community 2')
    c3 = create(Community, :name => 'Testing community 3')
    ActionTracker::Record.delete_all
    fast_create(ActionTracker::Record, :target_id => c1, :user_type => 'Profile', :user_id => person, :created_at => Time.now)
    fast_create(ActionTracker::Record, :target_id => c2, :user_type => 'Profile', :user_id => person, :created_at => Time.now)
    fast_create(ActionTracker::Record, :target_id => c2, :user_type => 'Profile', :user_id => person, :created_at => Time.now)
    get :communities, :filter => 'more_active'
    assert_equal [c2,c1,c3] , assigns(:results)
  end

  should 'filter more popular communities' do
    Person.delete_all
    Community.delete_all
    c1 = create(Community, :name => 'Testing community 1')
    c2 = create(Community, :name => 'Testing community 2')

    p1 = create(Person, :name => 'Testing person 1', :user_id => 1)
    p2 = create(Person, :name => 'Testing person 2', :user_id => 2)
    c1.add_member(p1)
    c2.add_member(p1)
    c2.add_member(p2)
    get :communities, :filter => 'more_popular'
    assert_equal [c2,c1] , assigns(:results)
  end

  should 'the communities filter be only the hardcoded one' do
    get :communities, :filter => 'more_recent'
    assert_equal 'more_recent' , assigns(:filter)

    get :communities, :filter => 'more_active'
    assert_equal 'more_active' , assigns(:filter)

    get :communities, :filter => 'more_popular'
    assert_equal 'more_popular' , assigns(:filter)

    get :communities, :filter => 'more_anything'
    assert_equal 'more_recent' , assigns(:filter)
  end

  should 'the communities filter define the title' do
    get :communities, :filter => 'more_recent'
    assert_equal 'More recent communities' , assigns(:title)
    assert_tag :h1, :content => 'More recent communities'

    get :communities, :filter => 'more_active'
    assert_equal 'More active communities' , assigns(:title)
    assert_tag :h1, :content => 'More active communities'

    get :communities, :filter => 'more_popular'
    assert_equal 'More popular communities' , assigns(:title)
    assert_tag :h1, :content => 'More popular communities'

    get :communities, :filter => 'more_anything'
    assert_equal 'More recent communities' , assigns(:title)
    assert_tag :h1, :content => 'More recent communities'
  end

  should "only include visible people in more_recent filter" do
    # assuming that all filters behave the same!
    p1 = fast_create(Person, :visible => false)
    get :people, :filter => 'more_recent'
    assert_not_includes assigns(:results), p1
  end

  should "only include visible communities in more_recent filter" do
    # assuming that all filters behave the same!
    p1 = fast_create(Community, :visible => false)
    get :communities, :filter => 'more_recent'
    assert_not_includes assigns(:results), p1
  end

  should 'search for contents' do
    small = create(TinyMceArticle, :name => 'Testing article', :body => 'A small article for testing', :profile => profile)
    create(TinyMceArticle, :name => 'Testing article 2', :body => 'A big article for testing', :profile => profile)

    get :contents, :query => 'small'
    assert_equal [small], assigns(:results)
  end

  should 'list all contents ordered by more recent by default' do
    c1 = create(TinyMceArticle, :name => 'Testing article 1', :body => 'Article body 1', :profile => profile, :created_at => DateTime.now - 2)
    c2 = create(TinyMceArticle, :name => 'Testing article 2', :body => 'Article body 2', :profile => profile, :created_at => DateTime.now - 1)
    c3 = create(TinyMceArticle, :name => 'Testing article 3', :body => 'Article body 3', :profile => profile)

    get :contents
    assert_equal [c3,c2,c1], assigns(:results)
  end

  should 'paginate search of contents in groups of 27' do
    1.upto(30).map do |n|
      create(TinyMceArticle, :name => "Testing article #{n}", :body => "Article body #{n}", :profile => profile)
    end

    get :contents
    assert_equal 27 , assigns(:results).count
    assert_tag :a, '', :attributes => {:class => 'next_page'}
  end

  should 'paginate ferret search of contents in groups of 27' do
    1.upto(30).map do |n|
      create(TinyMceArticle, :name => "Testing article #{n}", :body => "Article body #{n}", :profile => profile)
    end

    get :contents, :query => 'Testing'
    assert_equal 27 , assigns(:results).count
    assert_tag :a, '', :attributes => {:class => 'next_page'}
  end

  should 'list all contents filter by more comments' do
    article1 = fast_create(TinyMceArticle, :body => '<p>Article to test browse contents', :profile_id => profile.id, :comments_count => 5)
    article2 = fast_create(TinyMceArticle, :body => '<p>Another article to test browse contents</p>', :profile_id => profile.id, :comments_count => 10)
    article3 = fast_create(TinyMceArticle, :body => '<p>Another article to test browse contents</p>', :profile_id => profile.id, :comments_count => 1)

    get :contents, :filter => 'more_comments'
    assert_equal [article2,article1,article3] , assigns(:results)
  end

  should 'list all contents filter by more views' do
    article1 = fast_create(TinyMceArticle, :body => '<p>Article to test browse contents', :profile_id => profile.id, :hits => 5)
    article2 = fast_create(TinyMceArticle, :body => '<p>Another article to test browse contents</p>', :profile_id => profile.id, :hits => 10)
    article3 = fast_create(TinyMceArticle, :body => '<p>Another article to test browse contents</p>', :profile_id => profile.id, :hits => 1)

    get :contents, :filter => 'more_views'
    assert_equal [article2,article1,article3], assigns(:results)
  end

  should 'have the more_recent filter by default' do
    get :contents, :filter => 'more_recent'
    assert_equal 'more_recent' , assigns(:filter)

    get :contents, :filter => 'more_comments'
    assert_equal 'more_comments' , assigns(:filter)

    get :contents, :filter => 'more_views'
    assert_equal 'more_views' , assigns(:filter)

    get :contents, :filter => 'more_anything'
    assert_equal 'more_recent' , assigns(:filter)
  end

  should 'the contents filter define the title' do
    get :contents, :filter => 'more_recent'
    assert_equal 'More recent contents' , assigns(:title)
    assert_tag :h1, :content => 'More recent contents'

    get :contents, :filter => 'more_views'
    assert_equal 'Most viewed contents' , assigns(:title)
    assert_tag :h1, :content => 'Most viewed contents'

    get :contents, :filter => 'more_comments'
    assert_equal 'Most commented contents' , assigns(:title)
    assert_tag :h1, :content => 'Most commented contents'

    get :contents, :filter => 'more_anything'
    assert_equal 'More recent contents' , assigns(:title)
    assert_tag :h1, :content => 'More recent contents'
  end

  should "only include published contents in more_recent filter" do
    # assuming that all filters behave the same!
    article = fast_create(TinyMceArticle, :body => '<p>Article to test browse contents', :profile_id => profile.id, :published => false)
    get :contents, :filter => 'more_recent'
    assert_not_includes assigns(:results), article
  end

end
