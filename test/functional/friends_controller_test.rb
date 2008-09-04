require File.dirname(__FILE__) + '/../test_helper'
require 'friends_controller'

class FriendsController; def rescue_action(e) raise e end; end

class FriendsControllerTest < Test::Unit::TestCase

  noosfero_test :profile => 'testuser'

  def setup
    @controller = FriendsController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
    @response   = ActionController::TestResponse.new

    self.profile = create_user('testuser').person
    self.friend = create_user('thefriend').person
    login_as ('testuser')
  end
  attr_accessor :profile, :friend

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  should 'list friends' do
    get :index
    assert_response :success
    assert_template 'index'
    assert_kind_of Array, assigns(:friends)
  end

  should 'confirm addition of new friend' do
    get :add, :id => friend.id

    assert_response :success
    assert_template 'add'

    ok("must load the friend being added to display") { friend == assigns(:friend) } 

  end

  should 'actually add friend' do
    assert_difference AddFriend, :count do
      post :add, :id => friend.id, :confirmation => '1'
      assert_response :redirect
    end
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

    assert_difference Friendship, :count, -1 do
      post :remove, :id => friend.id, :confirmation => '1'
      assert_redirected_to :action => 'index'
    end
  end

end
