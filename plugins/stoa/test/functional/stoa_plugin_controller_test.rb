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
    @db = Tempfile.new('stoa-test')
    configs = ActiveRecord::Base.configurations['stoa'] = {:adapter => 'sqlite3', :database => @db.path}
    ActiveRecord::Base.establish_connection(:stoa)
    ActiveRecord::Schema.verbose = false
    ActiveRecord::Schema.create_table "pessoa" do |t|
      t.integer  "codpes"
      t.text     "numcpf"
      t.date     "dtanas"
    end
    ActiveRecord::Base.establish_connection(:test)
    env = Environment.default
    env.enable_plugin(StoaPlugin.name)
    env.enable('skip_new_user_email_confirmation')
    env.save!
    @user = create_user_full('real_user', {:password => '123456', :password_confirmation => '123456'}, {:usp_id => 9999999})
    StoaPlugin::UspUser.create!(:codpes => 12345678, :cpf => Digest::MD5.hexdigest(SALT+'12345678'), :birth_date => '1970-01-30')
  end

  def teardown
    @db.unlink
    @user.destroy
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
    get :check_usp_id, :usp_id => '12345678'
    assert json_response['exists']
  end

  should 'check invalid usp id' do
    get :check_usp_id, :usp_id => '87654321'
    assert !json_response['exists']
  end

  should 'check existent cpf' do
    get :check_cpf, :usp_id => '12345678'
    assert json_response['exists']
  end

  should 'check not existent cpf' do
    StoaPlugin::UspUser.create(:codpes => 87654321, :birth_date => '1970-01-30')
    get :check_cpf, :usp_id => '87654321'
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

