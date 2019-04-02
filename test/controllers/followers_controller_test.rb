require_relative '../test_helper'

class FollowersControllerTest < ActionController::TestCase
  def setup
    @profile = create_user('testuser').person
  end

  should 'return followed people list' do
    login_as(@profile.identifier)
    person = fast_create(Person)
    circle = Circle.create!(:person=> @profile, :name => "Zombies", :profile_type => 'Person')
    fast_create(ProfileFollower, :profile_id => person.id, :circle_id => circle.id)

    get :index, :profile => @profile.identifier
    assert_includes assigns(:followed_people), person
  end

  should 'return filtered followed people list' do
    login_as(@profile.identifier)
    person = fast_create(Person)
    community = fast_create(Community)
    circle = Circle.create!(:person=> @profile, :name => "Zombies", :profile_type => 'Person')
    circle2 = Circle.create!(:person=> @profile, :name => "Teams", :profile_type => 'Community')
    fast_create(ProfileFollower, :profile_id => person.id, :circle_id => circle.id)
    fast_create(ProfileFollower, :profile_id => community.id, :circle_id => circle2.id)

    get :index, :profile => @profile.identifier, :filter => "Community"
    assert_equal assigns(:followed_people), [community]

    get :index, :profile => @profile.identifier, :filter => "Person"
    assert_equal assigns(:followed_people), [person]
  end

  should 'redirect to login page if not logged in' do
    get :index, :profile => @profile.identifier
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  should 'render set category modal' do
    login_as(@profile.identifier)
    person = fast_create(Person)
    get :set_category_modal, :profile => @profile.identifier, :followed_profile_id => person.id
    assert_tag :tag => "input", :attributes => { :id => "followed_profile_id", :value => person.id }
  end

  should 'update followed person category' do
    login_as(@profile.identifier)
    person = fast_create(Person)
    circle = Circle.create!(:person=> @profile, :name => "Zombies", :profile_type => 'Person')
    circle2 = Circle.create!(:person=> @profile, :name => "DotA", :profile_type => 'Person')
    fast_create(ProfileFollower, :profile_id => person.id, :circle_id => circle.id)

    post :update_category, :profile => @profile.identifier, :circles => {"DotA"=> circle2.id}, :followed_profile_id => person.id
    assert_equivalent ProfileFollower.with_profile(person).with_follower(@profile).map(&:circle), [circle2]
  end

end
