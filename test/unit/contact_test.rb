require File.dirname(__FILE__) + '/../test_helper'

class ContactTest < ActiveSupport::TestCase

  should 'have serialized data' do
    t = Contact.new
    t.data[:test] = 'test'

    assert_equal({:test => 'test'}, t.data)
  end

  should 'validates required fields' do
    contact = Contact.new
    assert !contact.valid?
    contact.subject = 'Hi'
    assert !contact.valid?
    contact.email = 'visitor@invalid.com'
    assert !contact.valid?
    contact.message = 'Hi, all'
    assert !contact.valid?
    contact.target = create_user('contact_user_test').person
    assert contact.save!
  end

end
