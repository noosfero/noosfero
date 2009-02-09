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

  should 'display find people button' do
    get :index, :profile => 'testuser'
    assert_tag :tag => 'a', :content => 'Find people', :attributes => { :href => '/assets/people' }
  end

  should 'display invitation page' do
    get :invite
    assert_response :success
    assert_template 'invite'
  end

  should 'actualy add invite' do
    assert_difference InviteFriend, :count, 1 do
      post :invite, :manual_import_addresses => "Test Name <test@test.com>", :import_from => "manual", :message => "click: <url>", :confirmation => 1
      assert_redirected_to :action => 'index'
    end

    assert_difference InviteFriend, :count, 1 do
      post :invite, :manual_import_addresses => "test@test.com", :import_from => "manual", :message => "click: <url>", :confirmation => 1
      assert_redirected_to :action => 'index'
    end

    assert_difference InviteFriend, :count, 1 do
      post :invite, :manual_import_addresses => "test@test.cz.com", :import_from => "manual", :message => "click: <url>", :confirmation => 1
      assert_redirected_to :action => 'index'
    end

    assert_difference InviteFriend, :count, 1 do
      post :invite, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :message => "click: <url>", :confirmation => 1
      assert_redirected_to :action => 'index'
    end
  end
end
