require_relative "../test_helper"
require 'friends_controller'

class FriendsController; def rescue_action(e) raise e end; end

class FriendsControllerTest < ActionController::TestCase

  noosfero_test :profile => 'testuser'

  def setup
    @controller = FriendsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    self.profile = create_user('testuser').person
    self.friend = create_user('thefriend').person
    login_as ('testuser')
  end
  attr_accessor :profile, :friend

  should 'list friends' do
    get :index
    assert_response :success
    assert_template 'index'
    assert assigns(:friends)
  end

  should 'confirm removal of friend' do
    profile.add_friend(friend)

    get :remove, :id => friend.id
    assert_response :success
    assert_template 'remove'
    ok("must load the friend being removed") { friend == assigns(:friend) }
  end

  should 'actually remove friend' do
    profile.add_friend(friend)
    friend.add_friend(profile)

    assert_difference 'Friendship.count', -2 do
      post :remove, :id => friend.id, :confirmation => '1'
      assert_redirected_to :action => 'index'
    end
  end

  should 'display find people button' do
    get :index, :profile => 'testuser'
    assert_tag :tag => 'a', :content => 'Find people', :attributes => { :href => '/assets/people' }
  end

  should 'not display invite friends button if any plugin tells not to' do
    class Plugin1 < Noosfero::Plugin
      def remove_invite_friends_button
        true
      end
    end
    class Plugin2 < Noosfero::Plugin
      def remove_invite_friends_button
        false
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    e = profile.environment
    e.enable_plugin(Plugin1.name)
    e.enable_plugin(Plugin2.name)

    get :index, :profile => 'testuser'
    assert_no_tag :tag => 'a', :attributes => { :href => "/profile/testuser/invite/friends" }
  end

  should 'not display list suggestions button if there is no suggestion' do
    get :index, :profile => 'testuser'
    assert_no_tag :tag => 'a', :content => 'Suggest friends', :attributes => { :href => "/myprofile/testuser/friends/suggest" }
  end

  should 'display people suggestions' do
    profile.profile_suggestions.create(:suggestion => friend)
    get :suggest, :profile => 'testuser'
    assert_tag :tag => 'a', :content => "+ #{friend.name}", :attributes => { :href => "/profile/#{friend.identifier}/add" }
  end

  should 'display button to add friend suggestion' do
    profile.profile_suggestions.create(:suggestion => friend)
    get :suggest, :profile => 'testuser'
    assert_tag :tag => 'a', :attributes => { :href => "/profile/#{friend.identifier}/add" }
  end

  should 'display button to remove people suggestion' do
    profile.profile_suggestions.create(:suggestion => friend)
    get :suggest, :profile => 'testuser'
    assert_tag :tag => 'a', :attributes => { :href => /\/myprofile\/testuser\/friends\/remove_suggestion\/#{friend.identifier}/ }
  end

  should 'remove suggestion of friend' do
    suggestion = profile.profile_suggestions.create(:suggestion => friend)
    post :remove_suggestion, :profile => 'testuser', :id => friend.identifier

    assert_response :success
    assert_equal false, ProfileSuggestion.find(suggestion.id).enabled
  end

end
