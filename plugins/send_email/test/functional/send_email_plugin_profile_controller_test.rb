require 'test_helper'

class SendEmailPluginProfileControllerTest < ActionDispatch::IntegrationTest

  def setup
    @profile = fast_create(Community)
    environment = Environment.default
    environment.noreply_email = 'noreply@example.com'
    environment.save!
  end

  should 'not deliver emails via GET requests' do
    get send_email_plugin_profile_path(@profile.identifier, {action: :deliver})
    assert_response 403 # forbidden
  end

  should 'deliver emails only via POST requests' do
    post send_email_plugin_profile_path(@profile.identifier, {action: :deliver})
    assert_response :success
  end

  should 'render fail template if could not deliver mail' do
    post send_email_plugin_profile_path(@profile.identifier, {action: :deliver})
    assert_template 'fail'
  end

  should 'render success template after deliver mail' do
    SendEmailPlugin::Mail.any_instance.stubs(:valid?).returns(true)
    post send_email_plugin_profile_path(@profile.identifier, {action: :deliver}), params: {:to => 'john@example.com', :message => 'Hi john'}
    assert_template 'success'
  end

  should 'render dialog error if could not deliver mail by ajax request' do
    post send_email_plugin_profile_path(@profile.identifier, {action: :deliver}), xhr: true
    assert_template '_dialog_error_messages'
  end

  should 'render success message after deliver mail by ajax request' do
    SendEmailPlugin::Mail.any_instance.stubs(:valid?).returns(true)
    post send_email_plugin_profile_path(@profile.identifier, {action: :deliver}), params: {:to => 'john@example.com', :message => 'Hi john'}, xhr: true
    assert_equal 'Message sent', @response.body
  end

  should 'deliver mail' do
    Environment.any_instance.stubs(:send_email_plugin_allow_to).returns('john@example.com')
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      post send_email_plugin_profile_path(@profile.identifier, {action: :deliver}), params: {:to => 'john@example.com', :message => 'Hi john'}, xhr: true
    end
  end

  should 'deliver mail with nondefault subject' do
    Environment.any_instance.stubs(:send_email_plugin_allow_to).returns('john@example.com')
    post send_email_plugin_profile_path(@profile.identifier, {action: :deliver}), params: {:to => 'john@example.com', :message => 'Hi john', :subject => 'Hello john'}
    assert_equal '[Colivre.net] Hello john', ActionMailer::Base.deliveries.first.subject
  end

  should 'deliver mail with message from view' do
    Environment.any_instance.stubs(:send_email_plugin_allow_to).returns('john@example.com')
    post send_email_plugin_profile_path(@profile.identifier, {action: :deliver}), params: {:to => 'john@example.com', :message => 'Hi john', :subject => 'Hello john'}
    assert_match /Contact from/, ActionMailer::Base.deliveries.first.body.to_s
  end

end
