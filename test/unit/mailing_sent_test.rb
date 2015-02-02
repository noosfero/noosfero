require_relative "../test_helper"

class MailingSentTest < ActiveSupport::TestCase

  should 'return mailing and person' do
    person = fast_create(Person)
    environment = Environment.default
    mailing = environment.mailings.create(:subject => 'Hello', :body => 'We have some news')

    sent = mailing.mailing_sents.create(:person => person)

    mailing_sent = MailingSent.find(sent.id)
    assert_equal [mailing, person], [mailing_sent.mailing, mailing_sent.person]
  end
end
