require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/send_email_plugin_profile_controller'

# Re-raise errors caught by the controller.
class SendEmailPluginProfileController; def rescue_action(e) raise e end; end

def run_common_tests
  should 'not deliver emails via GET requests' do
    get :deliver, @extra_args
    assert_response 403 # forbidden
  end

  should 'deliver emails only via POST requests' do
    post :deliver, @extra_args
    assert_response :success
  end

  should 'render fail template if could not deliver mail' do
    post :deliver, @extra_args
    assert_template 'fail'
  end

  should 'render success template after deliver mail' do
    SendEmailPlugin::Mail.any_instance.stubs(:valid?).returns(true)
    post :deliver, @extra_args.merge(:to => 'john@example.com', :message => 'Hi john')
    assert_template 'success'
  end

  should 'render dialog error if could not deliver mail by ajax request' do
    xhr :post, :deliver, @extra_args
    assert_template '_dialog_error_messages'
  end

  should 'render success message after deliver mail by ajax request' do
    SendEmailPlugin::Mail.any_instance.stubs(:valid?).returns(true)
    xhr :post, :deliver, @extra_args.merge(:to => 'john@example.com', :message => 'Hi john')
    assert_equal 'Message sent', @response.body
  end

  should 'deliver mail' do
    Environment.any_instance.stubs(:send_email_plugin_allow_to).returns('john@example.com')
    assert_difference ActionMailer::Base.deliveries, :size do
      post :deliver, @extra_args.merge(:to => 'john@example.com', :message => 'Hi john')
    end
  end

  should 'deliver mail with nondefault subject' do
    Environment.any_instance.stubs(:send_email_plugin_allow_to).returns('john@example.com')
    post :deliver, @extra_args.merge(:to => 'john@example.com', :message => 'Hi john', :subject => 'Hello john')
    assert_equal '[Colivre.net] Hello john', ActionMailer::Base.deliveries.first.subject
  end
end

class SendEmailPluginProfileControllerTest < Test::Unit::TestCase
  def setup
    @controller = SendEmailPluginProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    community = fast_create(Community)
    @extra_args = {:profile => community.identifier}
  end

  run_common_tests()
end

class SendEmailPluginEnvironmentControllerTest < Test::Unit::TestCase
  def setup
    @controller = SendEmailPluginEnvironmentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @extra_args = {}
  end

  run_common_tests()
end
