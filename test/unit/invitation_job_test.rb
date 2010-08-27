require File.dirname(__FILE__) + '/../test_helper'

class InvitationJobTest < ActiveSupport::TestCase

  should 'invoke invitation' do
    contact_list = ContactList.create!
    person = create_user('maluquete').person
    contacts_to_invite = ['email1@example.com', 'email2@example.com']

    job = InvitationJob.new(person.id, contacts_to_invite, 'Hi!', person.id, contact_list.id)

    Invitation.expects(:invite).with(person, contacts_to_invite, 'Hi!', person)
    job.perform
  end

  should 'handle errors correctly' do
    assert_raise ActiveRecord::RecordNotFound do
      InvitationJob.new(-1, [], 'Booo!', -1, -1).perform
    end
  end

end
