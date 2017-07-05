require 'test_helper'

class MailingListPluginMyprofilePersonControllerTest < ActionController::TestCase

  def setup
    admin = create_user.person
    @person = create_user.person
    @community1 = fast_create(Community)
    @community1.add_member(admin)
    @community1.add_member(@person)
    @community2 = fast_create(Community)
    @community2.add_member(admin)
    @community2.add_member(@person)

    @client = mock
    @client.stubs(:login)
    Mail::Sympa.stubs(:new).returns(@client)

    login_as(@person.identifier)
  end

  should 'display all memberships but the templates' do
    template = fast_create(Community, is_template: true)
    template.add_member(@person)
    @client.stubs(:review).returns([@person.email])

    get :edit, profile: @person.identifier
    assert_tag 'a', content: @community1.name
    assert_tag 'a', content: @community2.name
    assert_no_tag 'a', content: template.name
  end

  should 'not open page if the mail lists server is offline' do
    MailingListPlugin::Client.stubs(:new).raises(StandardError)
    get :edit, profile: @person.identifier
    assert_redirected_to @person.admin_url
  end

  should 'display a unsubcribe button if the user is subscribed' do
    @client.stubs(:review).returns([@person.email])
    get :edit, profile: @person.identifier
    assert_tag 'a', attributes: { class: /.*icon-unsubscribe.*/ }
  end

  should 'display a subcribe button if the user is not subscribed' do
    @client.stubs(:review).returns(['no_subscribers'])
    get :edit, profile: @person.identifier
    assert_tag 'a', attributes: { class: /.*icon-subscribe.*/ }
  end

  should 'disable the subscribe button if there is a ongoing request' do
    @client.stubs(:review).returns(['no_subscribers'])
    MailingListPlugin::AcceptSubscription.stubs(:ongoing_subscription?)
                                         .returns(true)
    get :edit, profile: @person.identifier
    assert_tag 'a', attributes: { class: /.*icon-subscribe.*fetching.*/ }
  end

  should 'subscribe immediately if the user is an admin of the profile' do
    @community1.add_admin(@person)
    @client.stubs(:review).returns(['no_subscribers'])
    @client.expects(:add).once
    get :subscribe, profile: @person.identifier, id: @community1.id
  end

  should 'subscribe immediately if the user is an admin of the environment' do
    @community1.environment.add_admin(@person)
    @client.stubs(:review).returns(['no_subscribers'])
    @client.expects(:add).once
    get :subscribe, profile: @person.identifier, id: @community1.id
  end

  should 'subscribe immediately if the user was invited' do
    t = MailingListPlugin::SubscribeMember.new(target: @person,
                                               requestor: @person)
    t.metadata['group_id'] = @community1.id
    t.save

    @client.stubs(:review).returns(['no_subscribers'])
    @client.expects(:add).once
    get :subscribe, profile: @person.identifier, id: @community1.id

    t.reload
    assert_equal Task::Status::FINISHED, t.status
  end

  should 'create a task if the user is requesting for the first time' do
    assert_difference 'MailingListPlugin::AcceptSubscription.count' do
      get :subscribe, profile: @person.identifier, id: @community1.id
    end
  end

  should 'not subscribe if the user is already subscribed' do
    @community1.environment.add_admin(@person)
    @client.stubs(:review).returns(@person.email)
    @client.expects(:add).never
    get :subscribe, profile: @person.identifier, id: @community1.id
  end

  should 'not subscribe or create task if the user already requested to' do
    t = MailingListPlugin::AcceptSubscription.new(target: @community1,
                                                  requestor: @person)
    t.metadata['person_id'] = @person.id
    t.save

    @client.expects(:add).never
    assert_no_difference 'MailingListPlugin::AcceptSubscription.count' do
      get :subscribe, profile: @person.identifier, id: @community1.id
    end
  end

  should 'unsubscribe from the list' do
    @client.stubs(:review).returns(@person.email)
    @client.expects(:del).once
    get :unsubscribe, profile: @person.identifier, id: @community1.id
  end

  should 'not unsubscribe from the list if the user is not subscribed' do
    @client.stubs(:review).returns(['no_subscribers'])
    @client.expects(:del).never
    get :unsubscribe, profile: @person.identifier, id: @community1.id
  end

  should 'unsubscribe from all lists on a backgroung job' do
    @client.stubs(:review).returns(@person.email)
    get :unsubscribe_all, profile: @person.identifier

    @client.expects(:del).times(@person.memberships.count)
    process_delayed_job_queue
  end

end
