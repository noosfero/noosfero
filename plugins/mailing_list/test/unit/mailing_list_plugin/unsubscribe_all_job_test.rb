require 'test_helper'

class MailingListPlugin::UnsubscribeAllJobTest < ActiveSupport::TestCase
  def setup
    @client = mock
    MailingListPlugin::Client.stubs(:new).returns(@client)
  end

  attr_accessor :client

  should 'create a comment on an article if uuid belongs to article' do
    person = fast_create(Person)
    c1 = fast_create(Community)
    c2 = fast_create(Community)
    c3 = fast_create(Community)
    c1.add_member(person)
    c2.add_member(person)

    client.expects(:unsubscribe_person_from_group_list).with(person, c1).once
    client.expects(:unsubscribe_person_from_group_list).with(person, c2).once
    client.expects(:unsubscribe_person_from_group_list).with(person, c3).never

    job = MailingListPlugin::UnsubscribeAllJob.new(person.id)
    job.perform
  end
end
