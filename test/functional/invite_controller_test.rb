require File.dirname(__FILE__) + '/../test_helper'

class InviteControllerTest < ActionController::TestCase

  def setup
    @profile = create_user('testuser').person
    @friend = create_user('thefriend').person
    @community = fast_create(Community)
    login_as ('testuser')
  end
  attr_accessor :profile, :friend, :community

  should 'actually invite manually added address with friend object' do
    assert_difference InviteFriend, :count, 1 do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :step => 2
      assert_redirected_to :controller => 'friends'
    end
  end

  should 'actually invite manually added address with only e-mail' do
    assert_difference InviteFriend, :count, 1 do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "test@test.com", :import_from => "manual", :mail_template => "click: <url>", :step => 2
    end
  end

  should 'actually invite manually added addresses with e-mail and other format' do
    assert_difference InviteFriend, :count, 1 do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "test@test.cz.com", :import_from => "manual", :mail_template => "click: <url>", :step => 2
    end
  end

  should 'actually invite more than one manually added address' do
    assert_difference InviteFriend, :count, 2 do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "Some Friend <somefriend@email.com>\r\notherperson@bleble.net\r\n", :import_from => "manual", :mail_template => "click: <url>", :step => 2
    end
  end

  should 'actualy invite manually added addresses with name and e-mail' do
    assert_difference InviteFriend, :count, 1 do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "Test Name <test@test.com>", :import_from => "manual", :mail_template => "click: <url>", :step => 2
    end
  end

  should 'not invite yourself' do
    assert_no_difference InviteFriend, :count do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "#{profile.name} <#{profile.user.email}>", :import_from => "manual", :mail_template => "click: <url>", :step => 2
    end
  end

  should 'not invite if already a friend' do
    friend = create_user('testfriend', :email => 'friend@noosfero.org')
    friend.person.add_friend(profile)
    assert_no_difference InviteFriend, :count do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :step => 2
    end
  end

  should 'display invitation page' do
    get :friends, :profile => profile.identifier
    assert_response :success
    assert_tag :tag => 'h1', :content => 'Invite your friends'
  end

  should 'get mail template to invite members' do
    community.add_admin(profile)
    get :friends, :profile => community.identifier
    assert_equal InviteMember.mail_template, assigns(:mail_template)
  end

  should 'get mail template to invite friends' do
    community.add_admin(profile)
    get :friends, :profile => profile.identifier
    assert_equal InviteFriend.mail_template, assigns(:mail_template)
  end

  should 'deny if user has no rights to invite members' do
    get :friends, :profile => community.identifier
    assert_response 403 # forbidden
  end

  should 'deny access when trying to invite friends to another user' do
    get :friends, :profile => friend.identifier
    assert_response 403 # forbidden
  end

  should 'redirect to friends after invitation if profile is a person' do
    post :friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :step => 2
    assert_redirected_to :controller => 'friends'
  end

  should 'redirect to friends after invitation if profile is not a person' do
    community.add_admin(profile)
    post :friends, :profile => community.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :step => 2
    assert_redirected_to :controller => 'profile_members'
  end

end
