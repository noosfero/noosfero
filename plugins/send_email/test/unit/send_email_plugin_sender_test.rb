require File.dirname(__FILE__) + '/../../../../test/test_helper'

class SendEmailPluginSenderTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @environment = mock()
    @environment.stubs(:contact_email).returns('noreply@localhost')
    @environment.stubs(:default_hostname).returns('localhost')
    @environment.stubs(:name).returns('Noosfero')
    @environment.stubs(:send_email_plugin_allow_to).returns('john@example.com, someone@example.com, someother@example.com')
    @mail = SendEmailPlugin::Mail.new(:subject => 'Hi', :message => 'Hi john', :to => 'john@example.com', :from => 'noreply@localhost', :environment => @environment)
  end

  should 'be able to deliver mail' do
    response = SendEmailPlugin::Sender.send_message("http://localhost/contact", 'http//profile', @mail)
    assert_equal 'noreply@localhost', response.from.join
    assert_equal "[Noosfero] #{@mail.subject}", response.subject
  end

  should 'deliver mail to john@example.com' do
    response = SendEmailPlugin::Sender.send_message("http://localhost/contact", 'http//profile', @mail)
    assert_equal ['john@example.com'], response.to
  end

  should 'add each key value pair to message body' do
    @mail.params = {:param1 => 'value1', :param2 => 'value2'}
    response = SendEmailPlugin::Sender.send_message("http://localhost/contact", 'http//profile', @mail)
    assert_match /param1.+value1/m, response.body.to_s
    assert_match /param2.+value2/m, response.body.to_s
  end

end
