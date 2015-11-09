require 'test_helper'

class SendEmailPluginMailTest < ActiveSupport::TestCase

  def setup
    @environment = mock()
    @environment.stubs(:send_email_plugin_allow_to).returns('john@example.com, someone@example.com, someother@example.com')
  end

  should 'instance a valid object with fields to be fired in mail' do
    mail = SendEmailPlugin::Mail.new(:subject => 'Hi', :message => 'Hi john', :to => 'john@example.com', :environment => @environment)
    assert mail.valid?
  end

  should 'requires to field' do
    mail = SendEmailPlugin::Mail.new(:subject => 'Hi', :message => 'Hi john', :environment => @environment)
    refute mail.valid?
  end

  should 'require message field' do
    mail = SendEmailPlugin::Mail.new(:subject => 'Hi', :to => 'john@example.com', :environment => @environment)
    refute mail.valid?
  end

  should 'require environment field' do
    mail = SendEmailPlugin::Mail.new(:subject => 'Hi', :to => 'john@example.com', :message => 'Hi john')
    refute mail.valid?
  end

  should 'have a default subject' do
    mail = SendEmailPlugin::Mail.new
    assert_equal 'New mail', mail.subject
  end

  should 'not accept invalid email address' do
    mail = SendEmailPlugin::Mail.new(:subject => 'Hi', :message => 'Hi john', :to => 'invalid-mail-address', :environment => @environment)
    refute mail.valid?
  end

  should 'not accept email that is not in allowed address list' do
    mail = SendEmailPlugin::Mail.new(:subject => 'Hi', :message => 'Hi john', :to => 'unknow@example.com', :environment => @environment)
    refute mail.valid?
  end

  should 'discard some keys on set params hash' do
    mail = SendEmailPlugin::Mail.new(:params => {:action => 1, :controller => 2, :to => 3, :message => 4, :subject => 5, :age => 6})
    [:params].each do |k|
      refute mail.params.include?(k)
    end
    assert mail.params.include?(:age)
  end

  should "accept multiple 'to' emails" do
    mail = SendEmailPlugin::Mail.new(:subject => 'Hi', :message => 'Hi john', :to => 'john@example.com,someother@example.com', :environment => @environment)
    assert mail.valid?
  end

  should "invalid if just one listed in 'to' list was not allowed" do
    mail = SendEmailPlugin::Mail.new(:subject => 'Hi', :message => 'Hi john', :to => 'john@example.com,notallowed@example.com,someother@example.com', :environment => @environment)
    refute mail.valid?
  end

end
