require File.dirname(__FILE__) + '/../test_helper'

class InviteControllerTest < ActionController::TestCase

  def setup
    @profile = create_user('testuser').person
    @friend = create_user('thefriend').person
    @community = fast_create(Community)
    login_as ('testuser')
  end
  attr_accessor :profile, :friend, :community

  should 'add manually invitation of an added address with friend object on a queue and process it later' do
    assert_difference Delayed::Job, :count, 1 do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :step => 2
      assert_redirected_to :controller => 'friends'
    end

    assert_difference InviteFriend, :count, 1 do
      Delayed::Worker.new.work_off
    end
  end

  should 'add manually invitation of an added address with only email on a queue and process it later' do
    assert_difference Delayed::Job, :count, 1 do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "test@test.com", :import_from => "manual", :mail_template => "click: <url>", :step => 2
      assert_redirected_to :controller => 'friends'
    end

    assert_difference InviteFriend, :count, 1 do
      Delayed::Worker.new.work_off
    end
  end

  should 'add manually invitation of an added address with email and other format on a queue and process it later' do
    assert_difference Delayed::Job, :count, 1 do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "test@test.cz.com", :import_from => "manual", :mail_template => "click: <url>", :step => 2
      assert_redirected_to :controller => 'friends'
    end

    assert_difference InviteFriend, :count, 1 do
      Delayed::Worker.new.work_off
    end
  end

  should 'add manually invitation of more than one added address on a queue and process it later' do
    assert_difference Delayed::Job, :count, 1 do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "Some Friend <somefriend@email.com>\r\notherperson@bleble.net\r\n", :import_from => "manual", :mail_template => "click: <url>", :step => 2
      assert_redirected_to :controller => 'friends'
    end

    assert_difference InviteFriend, :count, 2 do
      Delayed::Worker.new.work_off
    end
  end

  should 'add manually invitation of an added address with name and e-mail on a queue and process it later' do
    assert_difference Delayed::Job, :count, 1 do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "Test Name <test@test.com>", :import_from => "manual", :mail_template => "click: <url>", :step => 2
      assert_redirected_to :controller => 'friends'
    end

    assert_difference InviteFriend, :count, 1 do
      Delayed::Worker.new.work_off
    end
  end

  should 'add invitation of yourself on a queue and not process it later' do
    assert_difference Delayed::Job, :count, 1 do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "#{profile.name} <#{profile.user.email}>", :import_from => "manual", :mail_template => "click: <url>", :step => 2
      assert_redirected_to :controller => 'friends'
    end

    assert_no_difference InviteFriend, :count do
      Delayed::Worker.new.work_off
    end
  end

  should 'add invitation of an already friend on a queue and not process it later' do
    friend = create_user('testfriend', :email => 'friend@noosfero.org')
    friend.person.add_friend(profile)

    assert_difference Delayed::Job, :count, 1 do
      post :friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :step => 2
      assert_redirected_to :controller => 'friends'
    end

    assert_no_difference InviteFriend, :count do
      Delayed::Worker.new.work_off
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
