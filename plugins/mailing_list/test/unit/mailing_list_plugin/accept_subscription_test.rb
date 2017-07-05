require 'test_helper'

class MailingListPlugin::AcceptSubscriptionTest < ActiveSupport::TestCase
  def setup
    requestor = fast_create(Person)
    @group = fast_create(Organization)
    @person = fast_create(Person)
    @task = MailingListPlugin::AcceptSubscription.new(requestor: requestor, target: @group)
    @task.metadata['person_id'] = @person.id
    @task.save!
  end

  attr_accessor :group, :person, :task

  should 'get person' do
    assert_equal person, task.person
  end

  should 'subscribe person on list on perform' do
    client = mock
    client.expects(:subscribe_person_on_group_list).with(person, group)
    client = MailingListPlugin::Client.stubs(:new).returns(client)
    task.perform
  end

  should 'check if there is an ongoing subscription' do
    assert MailingListPlugin::AcceptSubscription.ongoing_subscription?(person, group)

    client = mock
    client.expects(:subscribe_person_on_group_list).with(person, group)
    client = MailingListPlugin::Client.stubs(:new).returns(client)
    task.finish
    refute MailingListPlugin::AcceptSubscription.ongoing_subscription?(person, group)
  end
end
