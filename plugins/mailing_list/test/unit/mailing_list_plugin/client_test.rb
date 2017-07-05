require 'test_helper'

class MailingListPlugin::ClientTest < ActiveSupport::TestCase
  def setup
    @settings = mock
    @settings.stubs(:api_url)
    @settings.stubs(:administrator_email)
    @settings.stubs(:administrator_password)
    @sympa_client = mock
    @sympa_client.stubs(:login)
    Mail::Sympa.stubs(:new).returns(@sympa_client)
    @client = MailingListPlugin::Client.new(@settings)
  end

  attr_accessor :client, :sympa_client, :settings

  should 'list returns address before @' do
    l1 = mock
    l1.stubs(:listAddress).returns('my-list-1@example.org')
    l2 = mock
    l2.stubs(:listAddress).returns('my-list-2@example.org')
    l3 = mock
    l3.stubs(:listAddress).returns('my-list-3@example.org')
    sympa_client.stubs(:complex_lists).returns([l1, l2, l3])

    assert_equivalent %w(my-list-1 my-list-2 my-list-3), client.list
  end

  should 'review subscribers' do
    group = mock
    group.stubs(:identifier).returns('my-group')
    subscribers = ['subscriber1@example.org', 'subscriber2@example.org']
    sympa_client.stubs(:review).returns(subscribers)

    assert_equivalent subscribers, client.review(group)
  end

  should 'review return empty list when there are no subscribers' do
    group = mock
    group.stubs(:identifier).returns('my-group')
    sympa_client.stubs(:review).returns(['no_subscribers'])

    assert_empty client.review(group)
  end

  should 'get group list members' do
    group = mock
    group.stubs(:identifier).returns('my-group')
    s1 = create_user('subscriber1').person
    s2 = create_user('subscriber2').person
    s3 = create_user('non-subscriber').person
    subscribers = [s1.email, s2.email]
    sympa_client.stubs(:review).returns(subscribers)

    members = client.group_list_members(group)

    assert_includes members, s1
    assert_includes members, s2
    assert_not_includes members, s3
  end

  should 'check whether list exists' do
    group = mock
    group.stubs(:identifier).returns('my-list-1')
    l1 = mock
    l1.stubs(:listAddress).returns('my-list-1@example.org')
    l2 = mock
    l2.stubs(:listAddress).returns('my-list-2@example.org')
    l3 = mock
    l3.stubs(:listAddress).returns('my-list-3@example.org')
    sympa_client.stubs(:complex_lists).returns([l1, l2, l3])

    assert client.group_list_exist?(group)
  end

  should 'check whether a person is subscribed on a group list' do
    group = mock
    group.stubs(:identifier).returns('my-group')
    person = mock
    person.stubs(:email).returns('subscriber1@example.org')
    subscribers = [person.email, 'subscriber2@example.org']
    sympa_client.stubs(:review).returns(subscribers)

    assert client.person_subscribed_on_group_list?(person, group)
  end

  should 'cap identifier at 50 chars' do
    identifier = 'a'*60
    assert_equal 'a'*50, client.treat_identifier(identifier)
  end

  should 'use - to cap identifier in a more compreensible way' do
    identifier = ['a'*10, 'b'*20, 'c'*30].join('-')
    assert_equal ['a'*10, 'b'*20].join('-'), client.treat_identifier(identifier)
  end

  should 'create create list for a group' do
    group = mock
    group.stubs(:identifier).returns('my-group')
    group.stubs(:name).returns('My Group')
    m1 = mock
    m1.stubs(:email).returns('m1@example.org')
    m1.stubs(:name).returns('Member 1')
    m2 = mock
    m2.stubs(:email).returns('m2@example.org')
    m2.stubs(:name).returns('Member 2')

    group.stubs(:members).returns([m1, m2])
    client.stubs(:group_list_exist?).with(group).returns(false)
    sympa_client.stubs(:review).with(group.identifier).returns([])

    sympa_client.expects(:create_list).with(group.identifier, _("Mailing list of %s") % group.name)
    sympa_client.expects(:add).with(m1.email, group.identifier, m1.name)
    sympa_client.expects(:add).with(m2.email, group.identifier, m2.name)

    client.create_list_for_group(group)
  end

  should 'not create create list if it already exists' do
    group = mock
    group.stubs(:identifier).returns('my-group')
    group.stubs(:name).returns('My Group')
    group.stubs(:members).returns([])
    client.stubs(:group_list_exist?).with(group).returns(true)

    sympa_client.expects(:create_list).with(group.identifier, _("Mailing list of %s") % group.name).never
    client.create_list_for_group(group)
  end

  should 'close list for group' do
    group = mock
    group.stubs(:identifier).returns('my-group')
    group.stubs(:name).returns('My Group')
    m1 = mock
    m1.stubs(:email).returns('m1@example.org')
    m1.stubs(:name).returns('Member 1')
    m2 = mock
    m2.stubs(:email).returns('m2@example.org')
    m2.stubs(:name).returns('Member 2')

    group.stubs(:members).returns([m1, m2])
    sympa_client.stubs(:review).with(group.identifier).returns([m1.email, m2.email])

    sympa_client.expects(:del).with(m1.email, group.identifier)
    sympa_client.expects(:del).with(m2.email, group.identifier)

    client.close_list_for_group(group)
  end

  should 'subscribe person on group list' do
    group = mock
    group.stubs(:identifier).returns('my-group')
    group.stubs(:name).returns('My Group')
    member = mock
    member.stubs(:email).returns('m1@example.org')
    member.stubs(:name).returns('Member 1')
    sympa_client.stubs(:review).with(group.identifier).returns([])

    sympa_client.expects(:add).with(member.email, group.identifier, member.name)
    client.subscribe_person_on_group_list(member, group)
  end

  should 'unsubscribe person from group list' do
    group = mock
    group.stubs(:identifier).returns('my-group')
    group.stubs(:name).returns('My Group')
    member = mock
    member.stubs(:email).returns('m1@example.org')
    sympa_client.stubs(:review).with(group.identifier).returns([member.email])

    sympa_client.expects(:del).with(member.email, group.identifier)
    client.unsubscribe_person_from_group_list(member, group)
  end

  should 'deploy list for group' do
    group = mock
    group.stubs(:identifier).returns('my-group')
    group.stubs(:name).returns('My Group')
    m1 = mock
    m1.stubs(:email).returns('m1@example.org')
    m1.stubs(:name).returns('Member 1')
    m2 = mock
    m2.stubs(:email).returns('m2@example.org')
    m2.stubs(:name).returns('Member 2')

    group.stubs(:members).returns([m1, m2])
    client.stubs(:group_list_exist?).with(group).returns(false)
    sympa_client.stubs(:review).with(group.identifier).returns([])
    settings.stubs(:administrator_email).returns('admin@example.org')

    sympa_client.expects(:create_list).with(group.identifier, _("Mailing list of %s") % group.name)
    sympa_client.expects(:add).with(m1.email, group.identifier, m1.name)
    sympa_client.expects(:add).with(m2.email, group.identifier, m2.name)

    sympa_client.expects(:add).with(settings.administrator_email, group.identifier, _('Administrator'))
    client.deploy_list_for_group(group)
  end

  should 'pass missing methods to sympa client' do
    sympa_client.expects('missing_method').with('a1', 'a2')
    client.missing_method('a1', 'a2')
  end
end
