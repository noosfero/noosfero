require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/stoa_plugin_controller'

# Re-raise errors caught by the controller.
class StoaPluginController; def rescue_action(e) raise e end; end

class StoaPluginControllerTest < ActionController::TestCase

  def setup
    @controller = StoaPluginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @user = create_user('real_user', :password => '123456', :password_confirmation => '123456')
    environment = Environment.default
    environment.enabled_plugins = ['StoaPlugin']
    environment.save!
    @db = Tempfile.new('stoa-test')
    configs = ActiveRecord::Base.configurations['stoa'] = {:adapter => 'sqlite3', :database => @db.path}
  end

  attr_accessor :user

  should 'not authenticate if method not post' do
    @request.stubs(:ssl?).returns(true)
    get :authenticate, :login => user.login, :password => '123456'

    assert_not_nil json_response['error']
    assert_match /post method/,json_response['error']
  end

  should 'not authenticate if request is not using ssl' do
    @request.stubs(:ssl?).returns(false)
    post :authenticate, :login => user.login, :password => '123456'

    assert_not_nil json_response['error']
    assert_match /SSL/,json_response['error']
  end

  should 'not authenticate if method password is wrong' do
    @request.stubs(:ssl?).returns(true)
    post :authenticate, :login => user.login, :password => 'wrong_password'

    assert_not_nil json_response['error']
    assert_match /password/,json_response['error']
  end

  should 'authenticate if everything is right' do
    @request.stubs(:ssl?).returns(true)
    post :authenticate, :login => user.login, :password => '123456'

    assert_nil json_response['error']
    assert_equal user.login, json_response['username']
  end

  should 'check invalid usp id' do
    StoaPlugin::UspUser.stubs(:exists?).returns(false)
    get :check_usp_id, :usp_id => '987654321'
    assert !json_response['exists']
  end

  should 'check valid usp id' do
    StoaPlugin::UspUser.stubs(:exists?).returns(true)
    get :check_usp_id, :usp_id => '987654321'
    assert json_response['exists']
  end

  private

  def json_response
    ActiveSupport::JSON.decode @response.body
  end

end

