require File.dirname(__FILE__) + '/../test_helper'
require 'profile_controller'

# Re-raise errors caught by the controller.
class ProfileController; def rescue_action(e) raise e end; end

class ProfileControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testuser').person
  end

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  noosfero_test :profile => 'testuser'

  should 'list friends' do
    get :friends

    assert_response :success
    assert_template 'friends'
    assert_kind_of Array, assigns(:friends)
  end

  should 'list communities' do
    get :communities

    assert_response :success
    assert_template 'communities'
    assert_kind_of Array, assigns(:communities)
  end

  should 'list enterprises' do
    get :enterprises

    assert_response :success
    assert_template 'enterprises'
    assert_kind_of Array, assigns(:enterprises)
  end

  should 'list members (for organizations)' do
    get :members

    assert_response :success
    assert_template 'members'
    assert_kind_of Array, assigns(:members)
  end
  
  should 'list favorite enterprises' do
    get :favorite_enterprises

    assert_response :success
    assert_template 'favorite_enterprises'
    assert_kind_of Array, assigns(:favorite_enterprises)
  end

  should 'show Join This Community button for non-member users' do
    login_as(@profile.identifier)
    community = Community.create!(:name => 'my test community')
    get :index, :profile => community.identifier
    assert_tag :tag => 'a', :content => 'Join this community'
  end

  should 'not show Join This Community button for member users' do
    login_as(@profile.identifier)
    community = Community.create!(:name => 'my test community')
    community.add_member(@profile)
    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :content => 'Join this community'
  end

  should 'not show Join This Community button for non-registered users' do
    community = Community.create!(:name => 'my test community')
    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :content => 'Join this community'
  end

  should 'not show enterprises link to enterprise' do
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    get :index, :profile => ent.identifier
    assert_tag :tag => 'h2', :content => "#{ent.identifier}'s profile"
    assert_no_tag :tag => 'a', :content => 'Enterprises', :attributes => { :href => /profile\/#{ent.identifier}\/enterprises$/ }
  end

  should 'not show members link to person' do
    person = create_user('person_1').person
    get :index, :profile => person.identifier
    assert_tag :tag => 'h2', :content => "#{person.identifier}'s profile"
    assert_no_tag :tag => 'a', :content => 'Members', :attributes => { :href => /profile\/#{person.identifier}\/members$/ }
  end

  should 'show friends link to person' do
    person = create_user('person_1').person
    get :index, :profile => person.identifier
    assert_tag :tag => 'a', :content => 'Friends', :attributes => { :href => /profile\/#{person.identifier}\/friends$/ }
  end

  should 'not show homepage and feed automatically created on recent content' do
    person = create_user('person_1').person
    get :index, :profile => person.identifier
    assert_tag :tag => 'div', :content => 'Recent content', :attributes => { :class => 'block recent-documents-block' }, :child => { :tag => 'ul', :content => '' }
  end

  should 'show homepage on recent content after update' do
    person = create_user('person_1').person
    person.home_page.name = 'Changed name'
    assert person.home_page.save!
    get :index, :profile => person.identifier
    assert_tag :tag => 'div', :content => 'Recent content', :attributes => { :class => 'block recent-documents-block' }, :child => { :tag => 'ul', :content => /#{person.home_page.name}/ }
  end

  should 'show feed on recent content after update' do
    person = create_user('person_1').person
    person.articles.find_by_path('feed').name = 'Changed name'
    assert person.articles.find_by_path('feed').save!
    get :index, :profile => person.identifier
    assert_tag :tag => 'div', :content => 'Recent content', :attributes => { :class => 'block recent-documents-block' }, :child => { :tag => 'ul', :content => /#{person.articles.find_by_path('feed').name}/ }
  end

  should 'display tag for profile' do
    @profile.articles.create!(:name => 'testarticle', :tag_list => 'tag1')

    get :tag, :profile => @profile.identifier, :id => 'tag1'
    assert_tag :tag => 'a', :attributes => { :href => /testuser\/testarticle$/ }
  end

  should 'link to the same tag but for whole environment' do
    @profile.articles.create!(:name => 'testarticle', :tag_list => 'tag1')
    get :tag, :profile => @profile.identifier, :id => 'tag1'

    assert_tag :tag => 'a', :attributes => { :href => '/tag/tag1' }, :content => 'See content tagged with "tag1" in the entire site'
  end

  should 'show a link to own control panel' do
    login_as(@profile.identifier)
    get :index, :profile => @profile.identifier
    assert_tag :tag => 'ul', :attributes => { :class => 'profile-info-data' }, :descendant => { :tag => 'a', :content => 'Control panel' }
  end

  should 'not show a link to others control panel' do
    login_as(@profile.identifier)
    other = create_user('person_1').person
    get :index, :profile => other.identifier
    assert_no_tag :tag => 'ul', :attributes => { :class => 'profile-info-data' }, :descendant => { :tag => 'a', :content => 'Control panel' }
  end

  should 'show a link to control panel if user has profile_editor permission' do
    login_as(@profile.identifier)
    get :index, :profile => @profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{@profile.identifier}" }, :content => 'Control panel'
  end

  should 'show create community in own profile' do
    login_as(@profile.identifier)
    get :communities, :profile => @profile.identifier
    assert_tag :tag => 'a', :child => { :tag => 'span', :content => 'Create a new community' }
  end

  should 'not show create community on profile of other users' do
    login_as(@profile.identifier)
    person = create_user('person_1').person
    get :communities, :profile => person.identifier
    assert_no_tag :tag => 'a', :child => { :tag => 'span', :content => 'Create a new community' }
  end

  should 'not show Leave This Community button for non-member users' do
    login_as(@profile.identifier)
    community = Community.create!(:name => 'my test community')
    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :content => 'Leave this community'
  end

  should 'show Leave This Community button for member users' do
    login_as(@profile.identifier)
    community = Community.create!(:name => 'my test community')
    community.add_member(@profile)
    get :index, :profile => community.identifier
    assert_tag :tag => 'a', :content => 'Leave this community'
  end

  should 'not show Leave This Community button for non-registered users' do
    community = Community.create!(:name => 'my test community')
    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :content => 'Leave this community'
  end

  should 'check access before displaying profile' do
    Person.any_instance.expects(:display_info_to?).with(anything).returns(false)
    get :index, :profile => @profile.identifier
    assert_response 403
  end

  should 'display add friend button' do
    login_as(@profile.identifier)
    friend = create_user('friendtestuser').person
    get :index, :profile => friend.identifier
    assert_tag :tag => 'a', :content => 'Add friend'
  end

  should 'not display add friend button if user already request friendship' do
    friend = create_user('friendtestuser').person
    AddFriend.create!(:person => @profile, :friend => friend)
    get :index, :profile => friend.identifier
    assert_no_tag :tag => 'a', :content => 'Add friend'
  end

  should 'show message for disabled enterprise' do
    login_as(@profile.identifier)
    ent = Enterprise.create!(:name => 'my test enterprise', :identifier => 'my-test-enterprise', :enabled => false)
    get :index, :profile => ent.identifier
    assert_tag :tag => 'div', :attributes => { :id => 'profile-disabled' }, :content => Environment.default.message_for_disabled_enterprise
  end

  should 'not show message for disabled enterprise to non-enterprises' do
    login_as(@profile.identifier)
    @profile.enabled = false; @profile.save!
    get :index, :profile => @profile.identifier
    assert_no_tag :tag => 'div', :attributes => { :id => 'profile-disabled' }, :content => Environment.default.message_for_disabled_enterprise
  end

  should 'display "Products" link for enterprise' do
    ent = Enterprise.create!(:name => 'my test enterprise', :identifier => 'my-test-enterprise', :enabled => false)

    get :index, :profile => 'my-test-enterprise'
    assert_tag :tag => 'a', :attributes => { :href => '/catalog/my-test-enterprise'}, :content => /Products\/Services/
  end

  should 'not display "Products" link for people' do
    get :index, :profile => 'ze'
    assert_no_tag :tag => 'a', :attributes => { :href => '/catalog/my-test-enterprise'}, :content => /Products\/Services/
  end

  should 'display "Site map" link for profiles' do
    get :index, :profile => 'ze'
    assert_tag :tag => 'a', :content => "Site map", :attributes => { :href => '/profile/ze/sitemap' }
  end

  should 'list top level articles in sitemap' do
    get :sitemap, :profile => 'testuser'
    assert_equal @profile.top_level_articles, assigns(:articles)
  end

end
