require_relative "../test_helper"

class InviteControllerTest < ActionController::TestCase

  def setup
    @profile = create_user('testuser').person
    @friend = create_user('thefriend').person
    @community = fast_create(Community)
    login_as ('testuser')
    Delayed::Job.destroy_all
  end
  attr_accessor :profile, :friend, :community

  should 'add manually invitation of an added address with friend object on a queue and process it later' do
    contact_list = ContactList.create
    assert_difference 'Delayed::Job.count', 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_difference 'InviteFriend.count', 1 do
      process_delayed_job_queue
    end
  end

  should 'add manually invitation of an added address with only email on a queue and process it later' do
    contact_list = ContactList.create
    assert_difference 'Delayed::Job.count', 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "test@test.com", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_difference 'InviteFriend.count', 1 do
      process_delayed_job_queue
    end
  end

  should 'add manually invitation of an added address with email and other format on a queue and process it later' do
    contact_list = ContactList.create
    assert_difference 'Delayed::Job.count', 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "test@test.cz.com", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_difference 'InviteFriend.count', 1 do
      process_delayed_job_queue
    end
  end

  should 'add manually invitation of more than one added address on a queue and process it later' do
    contact_list = ContactList.create
    assert_difference 'Delayed::Job.count', 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "Some Friend <somefriend@email.com>\r\notherperson@bleble.net\r\n", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_difference 'InviteFriend.count', 2 do
      process_delayed_job_queue
    end
  end

  should 'add manually invitation of an added address with name and e-mail on a queue and process it later' do
    contact_list = ContactList.create
    assert_difference 'Delayed::Job.count', 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "Test Name <test@test.com>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_difference 'InviteFriend.count', 1 do
      process_delayed_job_queue
    end
  end

  should 'add invitation of yourself on a queue and not process it later' do
    contact_list = ContactList.create
    assert_difference 'Delayed::Job.count', 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "#{profile.name} <#{profile.user.email}>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_no_difference 'InviteFriend.count' do
      process_delayed_job_queue
    end
  end

  should 'add invitation of an already friend on a queue and not process it later' do
    friend = create_user('testfriend', :email => 'friend@noosfero.org')
    friend.person.add_friend(profile)

    contact_list = ContactList.create
    assert_difference 'Delayed::Job.count', 1 do
      post :select_friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_no_difference 'InviteFriend.count' do
      process_delayed_job_queue
    end
  end

  should 'display invitation page' do
    get :invite_friends, :profile => profile.identifier
    assert_response :success
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

  should 'deny invite_friends if user has no rights to invite members' do
    get :invite_friends, :profile => community.identifier
    assert_response 403 # forbidden
  end

  should 'deny select_friends if user has no rights to invite members' do
    get :select_friends, :profile => community.identifier
    assert_response 403 # forbidden
  end

  should 'deny invite_friends access when trying to invite friends to another user' do
    get :invite_friends, :profile => friend.identifier
    assert_response 403 # forbidden
  end

  should 'deny select_friends access when trying to invite friends to another user' do
    get :select_friends, :profile => friend.identifier
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
    assert_difference 'Delayed::Job.count', 1 do
      post :invite_friends, :profile => community.identifier, :contact_list => contact_list.id, :import_from => 'gmail'
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
    contact_list = create(ContactList, :fetched => true)
    get :invitation_data, :profile => profile.identifier, :contact_list => contact_list.id
    hash = {'fetched' => true, 'contact_list' => contact_list.id, 'error' => nil}

    assert_equal 'application/javascript', @response.content_type
    assert_equal hash, json_response
  end

  should 'render empty list of contacts' do
    contact_list = create(ContactList, :fetched => true)
    get :add_contact_list, :profile => profile.identifier, :contact_list => contact_list.id

    assert_response :success
    assert_template '_contact_list'
    assert_no_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => 'webmail_import_addresses[]'})
  end

  should 'render list of contacts' do
    contact_list = create(ContactList, :fetched => true, :list => ['email1@noosfero.org', 'email2@noosfero.org'])
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

    assert_difference 'ContactList.count', -1 do
      get :cancel_fetching_emails, :profile => profile.identifier, :contact_list => contact_list.id
    end
    assert_redirected_to :action => 'invite_friends'
  end

  should 'set locale in the background job' do
    @controller.stubs(:locale).returns('pt')

    contact_list = ContactList.create
    post :select_friends, :profile => profile.identifier, :manual_import_addresses => "#{friend.name} <#{friend.email}>", :import_from => "manual", :mail_template => "click: <url>", :contact_list => contact_list.id
    job = Delayed::Job.handler_like(InvitationJob.name).first
    assert_equal 'pt', job.payload_object.locale
  end

  should 'search friends profiles by name, email or identifier' do
    friend1 = create_user('willy').person
    friend2 = create_user('william').person
    friend1.name = 'cris'
    friend2.email = 'me@example.com'
    friend1.save
    friend2.save

    get :search, :profile => profile.identifier, :q => 'me@'

    assert_equal 'text/html', @response.content_type
    assert_equal [{"id" => friend2.id, "name" => friend2.name}].to_json, @response.body

    get :search, :profile => profile.identifier, :q => 'cri'

    assert_equal [{"id" => friend1.id, "name" => friend1.name}].to_json, @response.body

    get :search, :profile => profile.identifier, :q => 'will'

    assert_equivalent [{"id" => friend1.id, "name" => friend1.name}, {"id" => friend2.id, "name" => friend2.name}], json_response
  end

  should 'not include members in search friends profiles' do
    community.add_admin(profile)
    friend1 = create_user('willy').person
    friend2 = create_user('william').person
    friend1.save
    friend2.save

    community.add_member(friend2)

    get :search, :profile => community.identifier, :q => 'will'

    assert_equivalent [{"name" => friend1.name, "id" => friend1.id}], json_response
  end

  should 'not include friends in search for people to request friendship' do
    friend1 = create_user('willy').person
    friend2 = create_user('william').person

    profile.add_friend friend1
    friend1.add_friend profile
    profile.add_friend friend2
    friend2.add_friend profile

    get :search, :profile => profile.identifier, :q => 'will'

    assert_empty json_response
  end

  should 'invite registered users through profile id' do
    friend1 = create_user('testuser1').person
    friend2 = create_user('testuser2').person
    assert_difference 'Delayed::Job.count', 1 do
      post :invite_registered_friend, :profile => profile.identifier, :q => "#{friend1.id},#{friend2.id}", :mail_template => "click: <url>"
      assert_redirected_to :controller => 'profile', :action => 'friends'
    end

    assert_difference 'InviteFriend.count', 2 do
      process_delayed_job_queue
    end
  end

  private

  def json_response
    ActiveSupport::JSON.decode @response.body
  end


end
