require_relative "../test_helper"

class ContactListTest < ActiveSupport::TestCase

  should 'have list as an array' do
    assert_equal [], ContactList.create.list
  end

  should 'display list' do
    contact_list = ContactList.create.tap do |c|
      c.list = ['email1@noosfero.org', 'email2@noosfero.org']
    end

    assert_equal ['email1@noosfero.org', 'email2@noosfero.org'], contact_list.list
  end

  should 'return empty hash if contact list was not fetched' do
    contact_list = ContactList.create
    assert_equal({}, contact_list.data)
  end

  should 'return hash if contact list was fetched' do
    contact_list = ContactList.create.tap do |c|
      c.fetched = true
    end
    assert_equal({"fetched" => true, "contact_list" => contact_list.id, "error" => contact_list.error_fetching}, contact_list.data)
  end

  should 'update fetched and error_fetching when register auth error' do
    contact_list = ContactList.create
    assert_equal({}, contact_list.data)

    contact_list.register_error
    assert_equal({"fetched" => true, "contact_list" => contact_list.id, "error" => 'There was an error while looking for your contact list. Please, try again'}, contact_list.data)
  end

  should 'update fetched and error_fetching when register error' do
    contact_list = ContactList.create
    assert_equal({}, contact_list.data)

    contact_list.register_auth_error
    assert_equal({"fetched" => true, "contact_list" => contact_list.id, "error" => 'There was an error while authenticating. Did you enter correct login and password?'}, contact_list.data)
  end

end
