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
    contact_list = ContactList.create
    assert_difference Delayed::Job, :count, 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_difference InviteFriend, :count, 1 do
      process_delayed_job_queue
    end
  end

  should 'add manually invitation of an added address with only email on a queue and process it later' do
    contact_list = ContactList.create
    assert_difference Delayed::Job, :count, 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "test@test.com", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_difference InviteFriend, :count, 1 do
      process_delayed_job_queue
    end
  end

  should 'add manually invitation of an added address with email and other format on a queue and process it later' do
    contact_list = ContactList.create
    assert_difference Delayed::Job, :count, 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "test@test.cz.com", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_difference InviteFriend, :count, 1 do
      process_delayed_job_queue
    end
  end

  should 'add manually invitation of more than one added address on a queue and process it later' do
    contact_list = ContactList.create
    assert_difference Delayed::Job, :count, 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "Some Friend <somefriend@email.com>\r\notherperson@bleble.net\r\n", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_difference InviteFriend, :count, 2 do
      process_delayed_job_queue
    end
  end

  should 'add manually invitation of an added address with name and e-mail on a queue and process it later' do
    contact_list = ContactList.create
    assert_difference Delayed::Job, :count, 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "Test Name <test@test.com>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_difference InviteFriend, :count, 1 do
      process_delayed_job_queue
    end
  end

  should 'add invitation of yourself on a queue and not process it later' do
    contact_list = ContactList.create
    assert_difference Delayed::Job, :count, 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "#{profile.name} <#{profile.user.email}>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_no_difference InviteFriend, :count do
      process_delayed_job_queue
    end
  end

  should 'add invitation of an already friend on a queue and not process it later' do
    friend = create_user('testfriend', :email => 'friend@noosfero.org')
    friend.person.add_friend(profile)

    contact_list = ContactList.create
    assert_difference Delayed::Job, :count, 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_no_difference InviteFriend, :count do
      process_delayed_job_queue
    end
  end

  should 'display invitation page' do
    get :select_address_book, :profile => profile.identifier
    assert_response :success
    assert_tag :tag => 'h1', :content => 'Invite your friends'
  end

  should 'get mail template to invite members' do
    community.add_admin(profile)
    contact_list = ContactList.create
    get :select_friends, :profile => community.identifier, :contact_list => contact_list.id
    assert_equal InviteMember.mail_template, assigns(:mail_template)
  end

  should 'get mail template to invite friends' do
    community.add_admin(profile)
    contact_list = ContactList.create
    get :select_friends, :profile => profile.identifier, :contact_list => contact_list.id
    assert_equal InviteFriend.mail_template, assigns(:mail_template)
  end

  should 'deny select_address_book f user has no rights to invite members' do
    get :select_address_book, :profile => community.identifier
    assert_response 403 # forbidden
  end

  should 'deny select_friends if user has no rights to invite members' do
    get :select_friends, :profile => community.identifier
    assert_response 403 # forbidden
  end

  should 'deny select_address_book access when trying to invite friends to another user' do
    get :select_address_book, :profile => friend.identifier
    assert_response 403 # forbidden
  end

  should 'deny select_friends access when trying to invite friends to another user' do
    get :select_address_book, :profile => friend.identifier
    assert_response 403 # forbidden
  end

  should 'redirect to profile after invitation if profile is a person' do
    contact_list = ContactList.create
    post :select_friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
    assert_redirected_to :controller => 'profile', :action => 'friends'
  end

  should 'redirect to profile after invitation if profile is not a person' do
    community.add_admin(profile)
    contact_list = ContactList.create
    post :select_friends, :profile => community.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
    assert_redirected_to :controller => 'profile', :action => 'members'
  end

  should 'create a job to get emails after choose address book' do
    community.add_admin(profile)
    contact_list = ContactList.create
    assert_difference Delayed::Job, :count, 1 do
      post :select_address_book, :profile => community.identifier, :contact_list => contact_list.id, :import_from => 'gmail'
      assert_redirected_to :action => 'select_friends'
    end
  end

  should 'destroy contact_list after invitation when import is manual' do
    contact_list = ContactList.create
    post :select_friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id

    assert ContactList.exists?(contact_list.id)
    process_delayed_job_queue
    assert !ContactList.exists?(contact_list.id)
  end

  should 'destroy contact_list after invitation when import is not manual' do
    contact_list = ContactList.create
    post :select_friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "not_manual", :mail_template => "click: <url>", :contact_list => contact_list.id

    assert ContactList.exists?(contact_list.id)
    process_delayed_job_queue
    assert !ContactList.exists?(contact_list.id)
  end

  should 'return empty hash as invitation data if contact list was not fetched' do
    contact_list = ContactList.create
    get :invitation_data, :profile => profile.identifier, :contact_list => contact_list.id

    assert_equal 'application/javascript', @response.content_type
    assert_equal '{}', @response.body
  end

  should 'return hash as invitation data if contact list was fetched' do
    contact_list = ContactList.create(:fetched => true)
    get :invitation_data, :profile => profile.identifier, :contact_list => contact_list.id

    assert_equal 'application/javascript', @response.content_type
    assert_equal "{\"fetched\": true, \"contact_list\": #{contact_list.id}, \"error\": null}", @response.body
  end

  should 'render empty list of contacts' do
    contact_list = ContactList.create(:fetched => true)
    get :add_contact_list, :profile => profile.identifier, :contact_list => contact_list.id

    assert_response :success
    assert_template '_contact_list'
    assert_no_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => 'webmail_import_addresses[]'})
  end

  should 'render list of contacts' do
    contact_list = ContactList.create(:fetched => true, :list => ['email1@noosfero.org', 'email2@noosfero.org'])
    get :add_contact_list, :profile => profile.identifier, :contact_list => contact_list.id

    assert_response :success
    assert_template '_contact_list'

    i = 0
    contact_list.list.each do |contact|
      i += 1
      assert_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => 'webmail_import_addresses[]', :id => "contacts_to_invite_#{i}", :value => contact[2]})
    end
  end

  should 'destroy contact_list when cancel_fetching_emails' do
    contact_list = ContactList.create

    assert_difference ContactList, :count, -1 do
      get :cancel_fetching_emails, :profile => profile.identifier, :contact_list => contact_list.id
    end
    assert_redirected_to :action => 'select_address_book'
  end

  should 'set locale in the background job' do
    @controller.stubs(:locale).returns('pt')

    contact_list = ContactList.create
    post :select_friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
    assert_equal 'pt', Delayed::Job.first.payload_object.locale
  end

end
