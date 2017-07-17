require 'test_helper'

class MailingListPlugin::SubscribeMemberTest < ActiveSupport::TestCase
  def setup
    requestor = fast_create(Person)
    @group = fast_create(Organization)
    @person = fast_create(Person)
    @task = MailingListPlugin::SubscribeMember.new(requestor: requestor, target: @person)
    @task.metadata['group_id'] = @group.id
    task_mailer = mock
    task_mailer.stubs(:deliver)
    TaskMailer.stubs(:target_notification).returns(task_mailer)
    @task.save!
  end

  attr_accessor :group, :person, :task

  should 'get group' do
    assert_equal group, task.group
  end

  should 'subscribe person on list on perform' do
    client = mock
    client.expects(:subscribe_person_on_group_list).with(person, group)
    client = MailingListPlugin::Client.stubs(:new).returns(client)
    task.perform
  end

  should 'check if there is an ongoing subscription' do
    assert MailingListPlugin::SubscribeMember.ongoing_subscription?(person, group)

    client = mock
    client.expects(:subscribe_person_on_group_list).with(person, group)
    client = MailingListPlugin::Client.stubs(:new).returns(client)
    task.finish
    refute MailingListPlugin::SubscribeMember.ongoing_subscription?(person, group)
  end
end
