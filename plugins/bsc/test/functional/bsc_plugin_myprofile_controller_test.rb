require 'test_helper'
require_relative '../../controllers/bsc_plugin_myprofile_controller'

class BscPluginMyprofileControllerTest < ActionController::TestCase

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

  should 'do not list profiles template on search' do
    e1 = Enterprise.create!(:name => 'Sample Enterprise 1', :identifier => 'sample-enterprise-1')
    e2 = Enterprise.create!(:name => 'Sample Enterprise 2', :identifier => 'sample-enterprise-2')
    t1 = Enterprise.create!(:name => 'Enterprise template', :identifier => 'enterprise_template')
    t2 = Enterprise.create!(:name => 'Inactive enterprise template', :identifier => 'inactive_enterprise_template')

    get :search_enterprise, :profile => bsc.identifier, :q => 'ent'

    assert_no_match /#{t1.name}/, @response.body
    assert_no_match /#{t2.name}/, @response.body
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

  should 'fecth contracts filtered by status' do
    contract0 = BscPlugin::Contract.create!(:bsc => bsc, :status => 0, :client_name => 'Marvin')
    contract1 = BscPlugin::Contract.create!(:bsc => bsc, :status => 1, :client_name => 'Marvin')
    contract2 = BscPlugin::Contract.create!(:bsc => bsc, :status => 2, :client_name => 'Marvin')
    contract3 = BscPlugin::Contract.create!(:bsc => bsc, :status => 3, :client_name => 'Marvin')

    get :manage_contracts, :profile => bsc.identifier, :status => ['1', '3']

    assert_not_includes assigns(:contracts), contract0
    assert_includes assigns(:contracts), contract1
    assert_not_includes assigns(:contracts), contract2
    assert_includes assigns(:contracts), contract3
  end

  should 'manage contracts should have all status marked by default' do
    get :manage_contracts, :profile => bsc.identifier
    assert_equal assigns(:status), BscPlugin::Contract::Status.types.map { |s| s.to_s }
  end

  should 'fetch contracts sorted accordingly' do
    contract0 = BscPlugin::Contract.create!(:bsc => bsc, :created_at => 1.day.ago, :client_name => 'Eva')
    contract1 = BscPlugin::Contract.create!(:bsc => bsc, :created_at => 2.day.ago, :client_name => 'Adam')
    contract2 = BscPlugin::Contract.create!(:bsc => bsc, :created_at => 3.day.ago, :client_name => 'Marvin')

    by_date = [contract2, contract1, contract0]
    by_name = [contract1, contract0, contract2]

    get :manage_contracts, :profile => bsc.identifier, :sorting => 'created_at asc'
    assert_equal by_date, assigns(:contracts)

    get :manage_contracts, :profile => bsc.identifier, :sorting => 'created_at desc'
    assert_equal by_date.reverse, assigns(:contracts)

    get :manage_contracts, :profile => bsc.identifier, :sorting => 'client_name asc'
    assert_equal by_name, assigns(:contracts)

    get :manage_contracts, :profile => bsc.identifier, :sorting => 'client_name desc'
    assert_equal by_name.reverse, assigns(:contracts)
  end

  should 'limit the contracts to defined per page' do
    BscPlugin::Contract.create!(:bsc => bsc, :client_name => 'Marvin')
    BscPlugin::Contract.create!(:bsc => bsc, :client_name => 'Marvin')

    @controller.stubs(:contracts_per_page).returns(1)

    get :manage_contracts, :profile => bsc.identifier

    assert_equal 1, assigns(:contracts).count
  end

  should 'destroy contract' do
    contract = BscPlugin::Contract.create!(:bsc => bsc, :client_name => 'Marvin')

    assert_difference BscPlugin::Contract, :count, -1 do
      get :destroy_contract, :profile => bsc.identifier, :contract_id => contract.id
    end

    assert_raise ActiveRecord::RecordNotFound do
      BscPlugin::Contract.find(contract.id)
    end
  end

  should 'not crash if trying to destroy a contract that does not exists' do
    assert_nothing_raised do
      get :destroy_contract, :profile => bsc.identifier, :contract_id => -1
    end
    assert_redirected_to :action => 'manage_contracts'
  end

  should 'not crash if trying to edit a contract that does not exists' do
    assert_nothing_raised do
      get :edit_contract, :profile => bsc.identifier, :contract_id => -1
    end
    assert_redirected_to :action => 'manage_contracts'
  end

  should 'create contract associating the enterprises' do
    enterprise1 = fast_create(Enterprise)
    enterprise2 = fast_create(Enterprise)

    post :new_contract, :profile => bsc.identifier, :enterprises => "#{enterprise1.id},#{enterprise2.id}", :contract => {:bsc => bsc, :client_name => 'Marvin'}

    bsc.reload
    contract = bsc.contracts.last

    assert_includes contract.enterprises, enterprise1
    assert_includes contract.enterprises, enterprise2
  end

  should 'edit contract adding or removing enterprises accordingly' do
    enterprise1 = fast_create(Enterprise)
    enterprise2 = fast_create(Enterprise)
    enterprise3 = fast_create(Enterprise)
    contract = BscPlugin::Contract.create!(:bsc => bsc, :client_name => 'Marvin')
    contract.enterprises << enterprise1
    contract.enterprises << enterprise2

    post :edit_contract, :profile => bsc.identifier, :contract_id => contract.id, :enterprises => "#{enterprise2.id},#{enterprise3.id}", :contract => {:bsc => bsc}
    contract.reload

    assert_not_includes contract.enterprises, enterprise1
    assert_includes contract.enterprises, enterprise2
    assert_includes contract.enterprises, enterprise3
  end

  should 'not crash if there is no enterprises on create' do
    assert_nothing_raised do
      post :new_contract, :profile => bsc.identifier, :contract => {:bsc => bsc, :client_name => 'Marvin'}
    end
  end

  should 'create contract with associated sales' do
    product1 = fast_create(Product, :price => 2.50)
    product2 = fast_create(Product)
    sale1 = {:product_id => product1.id, :quantity => 2}
    sale2 = {:product_id => product2.id, :quantity => 5, :price => 3.50}
    sales = {1 => sale1, 2 => sale2}

    post :new_contract, :profile => bsc.identifier, :sales => sales, :contract => {:bsc => bsc, :client_name => 'Marvin'}

    bsc.reload
    contract = bsc.contracts.last

    assert_includes contract.products, product1
    assert_includes contract.products, product2

    assert_equal sale1[:quantity], contract.sales.find_by_product_id(sale1[:product_id]).quantity
    assert_equal sale2[:quantity], contract.sales.find_by_product_id(sale2[:product_id]).quantity
    assert_equal sale2[:price], contract.sales.find_by_product_id(sale2[:product_id]).price
  end

  should 'edit contract adding or removing sales accordingly' do
    product1 = fast_create(Product)
    product2 = fast_create(Product)
    product3 = fast_create(Product)
    contract = BscPlugin::Contract.create!(:bsc => bsc, :client_name => 'Marvin')
    BscPlugin::Sale.create!(:product => product1, :contract => contract, :quantity => 1)
    BscPlugin::Sale.create!(:product => product2, :contract => contract, :quantity => 1)
    sales = {1 => {:product_id => product2.id, :quantity => 1}, 2 => {:product_id => product3.id, :quantity => 1}}

    post :edit_contract, :profile => bsc.identifier, :contract_id => contract.id, :sales => sales , :contract => {:bsc => bsc}
    contract.reload

    assert_not_includes contract.products, product1
    assert_includes contract.products, product2
    assert_includes contract.products, product3
  end

  should 'edit sales informations' do
    product1 = fast_create(Product)
    product2 = fast_create(Product)
    contract = BscPlugin::Contract.create!(:bsc => bsc, :client_name => 'Marvin')
    sale1 = BscPlugin::Sale.create!(:product => product1, :contract => contract, :quantity => 1, :price => 1.0)
    sale2 = BscPlugin::Sale.create!(:product => product2, :contract => contract, :quantity => 2, :price => 2.0)
    sale2.save!
    sales = {1 => {:product_id => product1.id, :quantity => 3, :price => 5.0}, 2 => {:product_id => product2.id, :quantity => 4, :price => 10.0}}

    post :edit_contract, :profile => bsc.identifier, :contract_id => contract.id, :sales => sales , :contract => {:bsc => bsc}

    sale1.reload
    sale2.reload

    assert_equal 3, sale1.quantity
    assert_equal 5.0, sale1.price
    assert_equal 4, sale2.quantity
    assert_equal 10.0, sale2.price
  end

  should 'redirect to edit contract if some sale could not be created' do
    product = fast_create(Product)
    # sale without quantity
    sales = {1 => {:product_id => product.id, :price => 1.50}}

    post :new_contract, :profile => bsc.identifier, :sales => sales, :contract => {:bsc => bsc, :client_name => 'Marvin'}

    bsc.reload
    contract = bsc.contracts.last

    assert_redirected_to :action => 'edit_contract', :contract_id => contract.id
  end

  should 'search for products from the invoved enterprises' do
    # product1 fits
    # product2 doesn't fits because its in added_products
    # product3 doesn't fits because its enterprise is in enterprises
    enterprise1 = fast_create(Enterprise)
    enterprise2 = fast_create(Enterprise)
    enterprise3 = fast_create(Enterprise)
    product1 = fast_create(Product, :profile_id => enterprise1.id, :name => 'Black Bycicle')
    product2 = fast_create(Product, :profile_id => enterprise2.id, :name => 'Black Guitar')
    product3 = fast_create(Product, :profile_id => enterprise3.id, :name => 'Black Notebook')

    get :search_sale_product, :profile => bsc.identifier, :enterprises => [enterprise1.id,enterprise2.id].join(','), :added_products => [product2.id].join(','),:sales => {1 => {:product_id => 'black'}}

    assert_match /#{product1.name}/, @response.body
    assert_no_match /#{product2.name}/, @response.body
    assert_no_match /#{product3.name}/, @response.body
  end
end

