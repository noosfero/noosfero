require_relative "../test_helper"

class MailConfTest < ActiveSupport::TestCase

  should 'enable if told to' do
    NOOSFERO_CONF.stubs(:[]).with('mail_enabled').returns(true)
    assert_equal true, MailConf.enabled?
  end

  should 'disable if told to' do
    NOOSFERO_CONF.stubs(:[]).with('mail_enabled').returns(false)
    assert_equal false, MailConf.enabled?
  end

  should 'disable by default' do
    NOOSFERO_CONF.stubs(:[]).with('mail_enabled').returns(nil)
    assert_equal false, MailConf.enabled?
  end

  should 'provide webmail url preference' do
    NOOSFERO_CONF.stubs(:[]).with('webmail_url').returns('http://some.url/webmail/%s/%s')
    assert_equal 'http://some.url/webmail/login/example.com', MailConf.webmail_url('login', 'example.com')
  end

end
