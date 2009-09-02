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
    assert_equal friend, Profile.find(friend.id)
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

  should 'actualy invite manually added addresses with name and e-mail' do
    assert_difference InviteFriend, :count, 1 do
      post :invite, :manual_import_addresses => "Test Name <test@test.com>", :import_from => "manual", :message => "click: <url>", :confirmation => 1
      assert_redirected_to :action => 'index'
    end
  end

  should 'actualy invite manually added addresses with name and e-mail on wizard' do
    assert_difference InviteFriend, :count, 1 do
      post :invite, :manual_import_addresses => "Test Name <test@test.com>", :import_from => "manual", :message => "click: <url>", :confirmation => 1, :wizard => true
      assert_redirected_to :action => 'invite', :wizard => true
    end
  end

  should 'actually invite manually added address with only e-mail' do
    assert_difference InviteFriend, :count, 1 do
      post :invite, :manual_import_addresses => "test@test.com", :import_from => "manual", :message => "click: <url>", :confirmation => 1
      assert_redirected_to :action => 'index'
    end
  end

  should 'actually invite manually added address with only e-mail on wizard' do
    assert_difference InviteFriend, :count, 1 do
      post :invite, :manual_import_addresses => "test@test.com", :import_from => "manual", :message => "click: <url>", :confirmation => 1, :wizard => true
      assert_redirected_to :action => 'invite', :wizard => true
    end
  end

  should 'actually invite manually added addresses with e-mail and other format' do
    assert_difference InviteFriend, :count, 1 do
      post :invite, :manual_import_addresses => "test@test.cz.com", :import_from => "manual", :message => "click: <url>", :confirmation => 1
      assert_redirected_to :action => 'index'
    end
  end

  should 'actually invite manually added addresses with e-mail and other format on wizard' do
    assert_difference InviteFriend, :count, 1 do
      post :invite, :manual_import_addresses => "test@test.cz.com", :import_from => "manual", :message => "click: <url>", :confirmation => 1, :wizard => true
      assert_redirected_to :action => 'invite', :wizard => true
    end
  end

  should 'actually invite manually added address with friend object' do
    assert_difference InviteFriend, :count, 1 do
      post :invite, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :message => "click: <url>", :confirmation => 1
      assert_redirected_to :action => 'index'
    end
  end

  should 'actually invite manually added address with friend object on wizard' do
    assert_difference InviteFriend, :count, 1 do
      post :invite, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :message => "click: <url>", :confirmation => 1, :wizard => true
      assert_redirected_to :action => 'invite', :wizard => true
    end
  end

  should 'actually invite more than one manually added addres' do
    assert_difference InviteFriend, :count, 2 do
      post :invite, :manual_import_addresses => "Some Friend <somefriend@email.com>\r\notherperson@bleble.net\r\n", :import_from => "manual", :message => "click: <url>", :confirmation => 1
      assert_redirected_to :action => 'index'
    end
  end

  should 'actually invite more than one manually added addres on wizard' do
    assert_difference InviteFriend, :count, 2 do
      post :invite, :manual_import_addresses => "Some Friend <somefriend@email.com>\r\notherperson@bleble.net\r\n", :import_from => "manual", :message => "click: <url>", :confirmation => 1, :wizard => true
      assert_redirected_to :action => 'invite', :wizard => true
    end
  end

  should 'not invite yourself' do
    assert_no_difference InviteFriend, :count do
      post :invite, :manual_import_addresses => "#{profile.name} <#{profile.user.email}>", :import_from => "manual", :message => "click: <url>", :confirmation => 1, :wizard => true
    end
  end

  should 'not create InviteFriend if is a friend' do
    friend = create_user('testfriend', :email => 'friend@noosfero.org')
    friend.person.add_friend(profile)
    assert_no_difference InviteFriend, :count do
      post :invite, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :message => "click: <url>", :confirmation => 1, :wizard => true
    end
  end
end
