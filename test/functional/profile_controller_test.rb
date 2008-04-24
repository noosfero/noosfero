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

  should 'dont show enterprises link to enterprise' do
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    get :index, :profile => ent.identifier
    assert_tag :tag => 'h2', :content => "#{ent.identifier}'s profile"
    assert_no_tag :tag => 'a', :content => 'Enterprises', :attributes => { :href => /profile\/#{ent.identifier}\/enterprises$/ }
  end

  should 'dont show members link to person' do
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

end
