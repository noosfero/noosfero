require File.dirname(__FILE__) + '/../test_helper'

class GetEmailContactsJobTest < ActiveSupport::TestCase

  should 'register error' do
    contact_list = ContactList.create
    Invitation.expects(:get_contacts).with('from-email', 'mylogin', 'mypassword', contact_list.id).raises(Exception.new("crash"))

    job = GetEmailContactsJob.new('from-email', 'mylogin', 'mypassword', contact_list.id)
    job.perform

    assert ContactList.find(contact_list).fetched
    assert_equal 'There was an error while looking for your contact list. Please, try again', ContactList.find(contact_list).error_fetching
  end

  should 'register auth error' do
    contact_list = ContactList.create
    Invitation.expects(:get_contacts).with('from-email', 'mylogin', 'wrongpassword', contact_list.id).raises(Contacts::AuthenticationError)

    job = GetEmailContactsJob.new('from-email', 'mylogin', 'wrongpassword', contact_list.id)
    job.perform

    assert ContactList.find(contact_list).fetched
    assert_equal 'There was an error while authenticating. Did you enter correct login and password?', ContactList.find(contact_list).error_fetching
  end

end
