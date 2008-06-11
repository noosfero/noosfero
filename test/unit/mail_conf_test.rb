require File.dirname(__FILE__) + '/../test_helper'

class MailConfTest < ActiveSupport::TestCase

  CONFIG_FILE = '/not/existing.yml'

  should 'use config/mail.yml as config' do
    assert_equal RAILS_ROOT + '/config/mail.yml', MailConf.config_file
  end

  should 'enable if told to' do
    MailConf.stubs(:config_file).returns(CONFIG_FILE)
    File.expects(:exists?).with(CONFIG_FILE).returns(true)
    YAML.expects(:load_file).with(CONFIG_FILE).returns({ 'enabled' => true})
    assert_equal true, MailConf.enabled?
  end

  should 'disable if told to' do
    MailConf.stubs(:config_file).returns(CONFIG_FILE)
    File.expects(:exists?).with(CONFIG_FILE).returns(true)
    YAML.expects(:load_file).with(CONFIG_FILE).returns({ 'enabled' => false })
    assert_equal false, MailConf.enabled?
  end

  should 'disable if config file not present' do
    MailConf.stubs(:config_file).returns(CONFIG_FILE)
    File.expects(:exists?).with(CONFIG_FILE).returns(false)
    assert_equal false, MailConf.enabled?
  end

  should 'provide webmail url preference' do
    MailConf.stubs(:config_file).returns(CONFIG_FILE)
    File.expects(:exists?).with(CONFIG_FILE).returns(true)
    YAML.expects(:load_file).with(CONFIG_FILE).returns({ 'enabled' => false, 'webmail_url' => 'http://some.url/webmail' })
    assert_equal 'http://some.url/webmail', MailConf.webmail_url
  end

end
