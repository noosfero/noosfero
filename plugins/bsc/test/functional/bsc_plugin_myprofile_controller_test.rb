require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/bsc_plugin_myprofile_controller'
require File.dirname(__FILE__) + '/../../../../app/models/uploaded_file'

# Re-raise errors caught by the controller.
class BscPluginMyprofileController; def rescue_action(e) raise e end; end

class BscPluginMyprofileControllerTest < Test::Unit::TestCase

  VALID_CNPJ = '94.132.024/0001-48'

  def setup
    @controller = BscPluginMyprofileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @bsc = BscPlugin::Bsc.create!({:business_name => 'Sample Bsc', :identifier => 'sample-bsc', :company_name => 'Sample Bsc Ltda.', :cnpj => VALID_CNPJ})
    @admin = create_user('admin').person
    @bsc.add_admin(@admin)
    login_as(@admin.user.login)
    e = Environment.default
    e.enabled_plugins = ['BscPlugin']
    e.save!
  end

  attr_accessor :admin, :bsc

  should 'list enterprises on search' do
    # Should list if match name
    e1 = Enterprise.create!(:name => 'sample enterprise 1', :identifier => 'sample-enterprise-1')
    # Should be case insensitive
    e2 = Enterprise.create!(:name => 'SaMpLe eNtErPrIsE 2', :identifier => 'sample-enterprise-2')
    # Should not list if don't match name
    e3 = Enterprise.create!(:name => 'blo', :identifier => 'blo')
    # Should not list if is has a bsc
    e4 = Enterprise.create!(:name => 'sample enterprise 4', :identifier => 'sample-enterprise-4', :bsc => bsc)
    # Should not list if is enabled
    e5 = Enterprise.create!(:name => 'sample enterprise 5', :identifier => 'sample-enterprise-5', :enabled => true)
    BscPlugin::AssociateEnterprise.create!(:requestor => admin, :target => e5, :bsc => bsc)
    # Should search by identifier
    e6 = Enterprise.create!(:name => 'Bla', :identifier => 'sample-enterprise-6')

    get :search_enterprise, :profile => bsc.identifier, :q => 'sampl'
    
    assert_match /#{e1.name}/, @response.body
    assert_match /#{e2.name}/, @response.body
    assert_no_match /#{e3.name}/, @response.body
    assert_no_match /#{e4.name}/, @response.body
    assert_no_match /#{e5.name}/, @response.body
    assert_no_match /#{bsc.name}/, @response.body
    assert_match /#{e6.name}/, @response.body
  end

  should 'save associations' do
    e1 = fast_create(Enterprise, :enabled => false)
    e2 = fast_create(Enterprise, :enabled => false)

    post :save_associations, :profile => bsc.identifier, :q => "#{e1.id},#{e2.id}"
    e1.reload
    e2.reload
    assert_equal e1.bsc, bsc
    assert_equal e2.bsc, bsc

    post :save_associations, :profile => bsc.identifier, :q => "#{e1.id}"
    e1.reload
    e2.reload
    assert_equal e1.bsc, bsc
    assert_not_equal e2.bsc, bsc
  end

  should 'create a task to the enabled enterprise instead of associating it' do
    e = fast_create(Enterprise, :enabled => true)

    assert_difference BscPlugin::AssociateEnterprise, :count, 1 do
      post :save_associations, :profile => bsc.identifier, :q => "#{e.id}"
      bsc.reload
      assert_not_includes bsc.enterprises, e
    end
  end

  should 'transfer ownership' do
    p1 = create_user('p1').person
    p2 = create_user('p2').person
    p3 = create_user('p3').person

    role = Profile::Roles.admin(bsc.environment.id)

    bsc.add_admin(p1)
    bsc.add_admin(p2)

    post :transfer_ownership, :profile => bsc.identifier, 'q_'+role.key => "#{p3.id}"

    assert_response :redirect

    assert_not_includes bsc.admins, p1
    assert_not_includes bsc.admins, p2
    assert_includes bsc.admins, p3
  end

  should 'create enterprise' do
    assert_difference Enterprise, :count, 1 do
      post :create_enterprise, :profile => bsc.identifier, :create_enterprise => {:name => 'Test Bsc', :identifier => 'test-bsc'}
    end

    enterprise = Enterprise.find_by_identifier('test-bsc')

    assert_equal true, enterprise.enabled
    assert_equal false, enterprise.validated
    assert_equal enterprise.bsc, bsc
  end

end

