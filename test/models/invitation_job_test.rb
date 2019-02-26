require_relative "../test_helper"

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

  should 'change locale according to the locale informed' do
    job = InvitationJob.new(nil, nil, nil, nil, nil, 'pt')
    Noosfero.expects(:with_locale).with('pt')
    job.perform
  end

  should 'skip contact list deletion if it not exists' do
    contact_list = ContactList.create!
    person = create_user('maluquete').person
    job = InvitationJob.new(person.id, ['email1@example.com'], 'Hi!', person.id, contact_list.id)
    contact_list.destroy
    assert_nothing_raised do
      job.perform
    end
  end

end
