require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/stoa_plugin_controller'

# Re-raise errors caught by the controller.
class StoaPluginController; def rescue_action(e) raise e end; end

class StoaPluginControllerTest < ActionController::TestCase

  SALT=YAML::load(File.open(StoaPlugin.root_path + '/config.yml'))['salt']

  def setup
    @controller = StoaPluginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ActiveRecord::Base.configurations['stoa'] = {:adapter => 'sqlite3', :database => ':memory:', :verbosity => 'quiet'}
    env = Environment.default
    env.enable_plugin(StoaPlugin.name)
    env.enable('skip_new_user_email_confirmation')
    env.save!
    @user = create_user_full('real_user', {:password => '123456', :password_confirmation => '123456'}, {:usp_id => 9999999})
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

  should 'check valid usp id' do
    usp_id = '12345678'
    StoaPlugin::UspUser.stubs(:exists?).with(usp_id).returns(true)
    get :check_usp_id, :usp_id => usp_id
    assert json_response['exists']
  end

  should 'check invalid usp id' do
    usp_id = '87654321'
    StoaPlugin::UspUser.stubs(:exists?).with(usp_id).returns(false)
    get :check_usp_id, :usp_id => usp_id
    assert !json_response['exists']
  end

  should 'check existent cpf' do
    usp_id = '12345678'
    user = mock
    user.stubs(:cpf).returns('12345678')
    StoaPlugin::UspUser.stubs(:find_by_codpes).with(usp_id).returns(user)
    get :check_cpf, :usp_id => usp_id
    assert json_response['exists']
  end

  should 'check not existent cpf' do
    usp_id_with_cpf = '12345678'
    user_with_cpf = mock
    user_with_cpf.stubs(:cpf).returns('12345678')
    StoaPlugin::UspUser.stubs(:find_by_codpes).with(usp_id_with_cpf).returns(user_with_cpf)
    get :check_cpf, :usp_id => usp_id_with_cpf
    usp_id_without_cpf = '87654321'
    user_without_cpf = mock
    user_with_cpf.stubs(:cpf).returns(nil)
    StoaPlugin::UspUser.stubs(:find_by_codpes).with(usp_id_without_cpf).returns(user_without_cpf)
    get :check_cpf, :usp_id => usp_id_without_cpf
    assert !json_response['exists']
  end

  should 'authenticate with usp_id' do
    @request.stubs(:ssl?).returns(true)
    post :authenticate, :usp_id => user.person.usp_id.to_s, :password => '123456'

    assert_nil json_response['error']
    assert_equal user.login, json_response['username']
  end

  should 'not crash if usp_id is invalid' do
    @request.stubs(:ssl?).returns(true)
    assert_nothing_raised do
      post :authenticate, :usp_id => 12321123, :password => '123456'
    end
    assert_not_nil json_response['error']
    assert_match /user/,json_response['error']
  end

  private

  def json_response
    ActiveSupport::JSON.decode @response.body
  end

end

