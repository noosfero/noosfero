require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../../../app/controllers/public/account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActionController::TestCase

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    environment = Environment.default
    environment.enabled_plugins = ['StoaPlugin']
    environment.save!
    @db = Tempfile.new('stoa-test')
    configs = ActiveRecord::Base.configurations['stoa'] = {:adapter => 'sqlite3', :database => @db.path}
  end

  should 'fail if confirmation value doesn\'t match' do
    StoaPlugin::UspUser.stubs(:matches?).returns(false)
    post :signup, :profile_data => {:usp_id => '87654321'}, :confirmation_field => 'cpf', :confirmation_value => '00000000'
    assert_not_nil assigns(:person).errors[:usp_id]
  end

  should 'pass if confirmation value matches' do
    StoaPlugin::UspUser.stubs(:matches?).returns(true)
    post :signup, :profile_data => {:usp_id => '87654321'}, :confirmation_field => 'cpf', :confirmation_value => '12345678'
    assert_nil assigns(:person).errors[:usp_id]
  end

end
