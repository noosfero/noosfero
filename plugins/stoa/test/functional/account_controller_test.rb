require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../../../app/controllers/public/account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActionController::TestCase

  SALT=YAML::load(File.open(StoaPlugin.root_path + 'config.yml'))['salt']

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

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    StoaPlugin::UspUser.create!({:codpes => 12345678, :cpf => Digest::MD5.hexdigest(SALT+'12345678'), :birth_date => '1970-01-30'}, :without_protection => true)
    Environment.default.enable_plugin(StoaPlugin.name)
    @user = create_user('joao-stoa', {:password => 'pass', :password_confirmation => 'pass'},:usp_id=>'87654321')
    @user.activate
  end

  should 'fail if confirmation value doesn\'t match' do
    #StoaPlugin::UspUser.stubs(:matches?).returns(false)
    post :signup, :profile_data => {:usp_id => '12345678'}, :confirmation_field => 'cpf', :cpf => '00000000'
    assert_not_nil assigns(:person).errors[:usp_id]
  end

  should 'pass if confirmation value matches' do
    #StoaPlugin::UspUser.stubs(:matches?).returns(true)
    post :signup, :profile_data => {:usp_id => '12345678'}, :confirmation_field => 'cpf', :cpf => '12345678'
    assert !assigns(:person).errors.include?(:usp_id)
  end

  should 'include invitation_code param in the person\'s attributes' do
    get :signup, :invitation_code => 12345678
    assert assigns(:person).invitation_code == '12345678'
  end

  should 'authenticate with usp id' do
    post :login, :usp_id_login => '87654321', :password => 'pass'
    assert session[:user]
    assert_equal @user.login, assigns(:current_user).login
  end

  should 'not authenticate with wrong password' do
    post :login, :usp_id_login => '87654321', :password => 'pass123'
    assert_nil session[:user]
  end

  should 'authenticate with username' do
    post :login, :usp_id_login => 'joao-stoa', :password => 'pass'
    assert session[:user]
    assert_equal @user.login, assigns(:current_user).login
  end

  should 'be able to recover password with usp_id' do
    post :forgot_password, :value => '87654321'
    assert_template 'password_recovery_sent'
  end
end
