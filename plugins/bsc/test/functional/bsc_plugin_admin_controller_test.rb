require 'test_helper'
require_relative '../../controllers/bsc_plugin_admin_controller'

class BscPluginAdminControllerTest < ActionController::TestCase

  VALID_CNPJ = '94.132.024/0001-48'

  def setup
    @controller = BscPluginAdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    user_login = create_admin_user(Environment.default)
    login_as(user_login)
    @admin = User[user_login].person
    e = Environment.default
    e.enabled_plugins = ['BscPlugin']
    e.save!
  end

  attr_accessor :admin

  should 'create a new bsc' do
    assert_difference BscPlugin::Bsc, :count, 1 do
      post :new, :profile_data => {:business_name => 'Sample Bsc', :identifier => 'sample-bsc', :company_name => 'Sample Bsc Ltda.', :cnpj => VALID_CNPJ}
    end

    assert_redirected_to :controller => 'profile_editor', :profile => 'sample-bsc'
  end

  should 'not create an invalid bsc' do
    assert_difference BscPlugin::Bsc, :count, 0 do
      post :new, :profile_data => {:business_name => 'Sample Bsc', :identifier => 'sample-bsc', :company_name => 'Sample Bsc Ltda.', :cnpj => '29837492304'}
    end

    assert_response 200
  end

  should 'set the current user as the bsc admin' do
    name = 'Sample Bsc'
    post :new, :profile_data => {:business_name => name, :identifier => 'sample-bsc', :company_name => 'Sample Bsc Ltda.', :cnpj => VALID_CNPJ}
    bsc = BscPlugin::Bsc.find_by_name(name)
    assert_includes bsc.admins, admin
  end

  should 'list correct enterprises on search' do
    # Should list if: not validated AND (name matches OR identifier matches) AND not bsc
    e1 = Enterprise.create!(:name => 'Sample Enterprise 1', :identifier => 'bli', :validated => false)
    e2 = Enterprise.create!(:name => 'Bla', :identifier => 'sample-enterprise-6', :validated => false)
    e3 = Enterprise.create!(:name => 'Blo', :identifier => 'blo', :validated => false)
    e4 = BscPlugin::Bsc.create!(:business_name => "Sample Bsc", :identifier => 'sample-bsc', :company_name => 'Sample Bsc Ltda.', :cnpj => VALID_CNPJ, :validated => false)
    e5 = Enterprise.create!(:name => 'Sample Enterprise 5', :identifier => 'sample-enterprise-5')
    e5.validated = true
    e5.save!

    get :search_enterprise, :q => 'sampl'

    assert_match /#{e1.name}/, @response.body
    assert_match /#{e2.name}/, @response.body
    assert_no_match /#{e3.name}/, @response.body
    assert_no_match /#{e4.name}/, @response.body
    assert_no_match /#{e5.name}/, @response.body
  end

  should 'save validations' do
    e1 = fast_create(Enterprise, :validated => false)
    e2 = fast_create(Enterprise, :validated => false)
    e3 = fast_create(Enterprise, :validated => false)

    post :save_validations, :q => "#{e1.id},#{e2.id}"
    e1.reload
    e2.reload
    e3.reload

    assert e1.validated
    assert e2.validated
    assert !e3.validated
  end
end
