require File.dirname(__FILE__) + '/../test_helper'

class MailingSentTest < ActiveSupport::TestCase

  should 'return mailing and person' do
    person = fast_create(Person)
    mailing = Mailing.create(:source => Environment.default, :subject => 'Hello', :body => 'We have some news')
    sent = MailingSent.create(:mailing => mailing, :person => person)

    mailing_sent = MailingSent.find(sent.id)
    assert_equal [mailing, person], [mailing_sent.mailing, mailing_sent.person]
  end
end
