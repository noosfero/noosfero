require File.dirname(__FILE__) + '/../test_helper'

class MailConfTest < ActiveSupport::TestCase

  should 'enable if told to' do
    NOOSFERO_CONF['mail_enabled'] = true
    assert_equal true, MailConf.enabled?
  end

  should 'disable if told to' do
    NOOSFERO_CONF['mail_enabled'] = false
    assert_equal false, MailConf.enabled?
  end

  should 'disable by default' do
    NOOSFERO_CONF['mail_enabled'] = nil
    assert_equal false, MailConf.enabled?
  end

  should 'provide webmail url preference' do
    NOOSFERO_CONF['webmail_url'] = 'http://some.url/webmail/%s/%s'
    assert_equal 'http://some.url/webmail/login/example.com', MailConf.webmail_url('login', 'example.com')
  end

end
