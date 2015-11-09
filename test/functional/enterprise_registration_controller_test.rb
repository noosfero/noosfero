require_relative "../test_helper"
require 'enterprise_registration_controller'

class EnterpriseRegistrationControllerTest < ActionController::TestCase

  # all_fixtures:users
  all_fixtures

  def setup
    super
    @controller = EnterpriseRegistrationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as 'ze'
  end

  should 'go to the first step on index' do
    get :index
    assert_response :success
    assert_template 'basic_information'
  end

  should 'get back to entering basic information if data is invalid' do
    post :index, :create_enterprise => {}
    assert_response :success
    assert_template 'basic_information'
  end

  should 'skip prompt for selection validator if approval method is admin' do
    env = Environment.default
    env.organization_approval_method = :admin
    env.save
    region = fast_create(Region, {})

    data = { :name => 'My new enterprise', :identifier => 'mynew', :region_id => region.id }
    create_enterprise = CreateEnterprise.new(data)

    post :index, :create_enterprise => data
    assert_template 'confirmation'
  end

  should 'skip prompt for selection validator if approval method is none' do
    env = Environment.default
    env.organization_approval_method = :none
    env.save
    region = fast_create(Region, {})

    data = { :name => 'My new enterprise', :identifier => 'mynew', :region_id => region.id }
    create_enterprise = CreateEnterprise.new(data)

    post :index, :create_enterprise => data
    assert_template 'creation'
  end

  should 'show template welcome page on creation view' do
    env = Environment.default
    env.organization_approval_method = :none
    env.save
    region = fast_create(Region, {})

    template = Enterprise.create!(:name => 'Enterprise Template', :identifier => 'enterprise-template', :is_template => true)
    welcome_page = TinyMceArticle.create!(:name => 'Welcome Page', :profile => template, :body => 'This is the welcome page of enterprise template.', :published => true)
    template.welcome_page = welcome_page
    template.save!

    data = { :name => 'My new enterprise', :identifier => 'mynew', :region_id => region.id, :template_id => template.id }
    create_enterprise = CreateEnterprise.new(data)

    post :index, :create_enterprise => data
    assert_match /#{welcome_page.body}/, @response.body
  end

  should 'prompt for selecting validator if approval method is region' do
    env = Environment.default
    env.organization_approval_method = :region
    env.save
    data = { 'name' => 'My new enterprise', 'identifier' => 'mynew' }

    create_enterprise = CreateEnterprise.new
    CreateEnterprise.expects(:new).with(data).returns(create_enterprise)

    validator1 = mock()
    validator1.expects(:id).returns(1)
    validator1.expects(:name).returns("validator1")
    validator1.expects(:validation_methodology).returns("methodology1")
    validator1.expects(:validation_restrictions).returns("restrictions1")

    validator2 = mock()
    validator2.expects(:id).returns(2)
    validator2.expects(:name).returns("validator2")
    validator2.expects(:validation_methodology).returns("methodology2")
    validator2.expects(:validation_restrictions).returns("restrictions2")


    region = mock()
    region.expects(:validators).returns([validator1, validator2]).at_least_once
    create_enterprise.expects(:region).returns(region)

    # all data but validator selected
    create_enterprise.expects(:valid_before_selecting_target?).returns(true)
    create_enterprise.stubs(:valid?).returns(false)

    post :index, :create_enterprise => data
    assert_template 'select_validator'
  end

  should 'provide confirmation at the end of the process' do
    data = { 'name' => 'My new enterprise', 'identifier' => 'mynew' }

    create_enterprise = CreateEnterprise.new
    CreateEnterprise.expects(:new).with(data).returns(create_enterprise)

    # all including validator selected
    validator = mock()
    validator.stubs(:name).returns("lalala")
    create_enterprise.expects(:valid_before_selecting_target?).returns(true)
    create_enterprise.stubs(:valid?).returns(true) # validator already selected
    create_enterprise.expects(:save!)
    create_enterprise.expects(:target).returns(validator)

    post :index, :create_enterprise => data
    assert_template 'confirmation'
  end

  should 'filter html from name' do
    post :index, :create_enterprise => { 'name' => '<b>name</b>', 'identifier' => 'mynew' }
    assert_sanitized assigns(:create_enterprise).name
  end

  should 'filter html from address' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :address => '<b>address</b>' }
    assert_sanitized assigns(:create_enterprise).address
  end

  should 'filter html from contact_phone' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :contact_phone => '<b>contact_phone</b>' }
    assert_sanitized assigns(:create_enterprise).contact_phone
  end

  should 'filter html from contact_person' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :contact_person => '<b>contact_person</b>' }
    assert_sanitized assigns(:create_enterprise).contact_person
  end

  should 'filter html from acronym' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :acronym => '<b>acronym</b>' }
    assert_sanitized assigns(:create_enterprise).acronym
  end

  should 'filter html from legal_form' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :legal_form => '<b>legal_form</b>' }
    assert_sanitized assigns(:create_enterprise).legal_form
  end

  should 'filter html from economic_activity' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :economic_activity => '<b>economic_activity</b>' }
    assert_sanitized assigns(:create_enterprise).economic_activity
  end

  should 'filter html from management_information' do
    post :index, :create_enterprise => { 'name' => 'name', 'identifier' => 'mynew', :management_information => '<b>management_information</b>' }
    assert_sanitized assigns(:create_enterprise).management_information
  end

  should 'load only regions with validator organizations if approval method is region' do
    env = Environment.default
    env.organization_approval_method = :region
    env.save

    reg1 = env.regions.create!(:name => 'Region with validator')
    reg1.validators.create!(:name => 'Validator one', :identifier => 'validator-one')
    reg2 = env.regions.create!(:name => 'Region without validator')

    get :index

    assert_includes assigns(:regions), [reg1.name, reg1.id]
    assert_tag :tag => 'option', :content => "Region with validator"
    assert_no_tag :tag => 'option', :content => "Region without validator"
  end

  should 'set current environment as the task target if approval method is admin' do
    environment = Environment.new(:name => "Another environment")
    environment.organization_approval_method = :admin
    environment.save
    @controller.stubs(:environment).returns(environment)

    get :index
    assert_equal assigns(:create_enterprise).target, environment
  end

  should 'include hidden fields supplied by plugins on enterprise registration' do
    class Plugin1 < Noosfero::Plugin
      def enterprise_registration_hidden_fields
        {'plugin1' => 'Plugin 1'}
      end
    end

    class Plugin2 < Noosfero::Plugin
      def enterprise_registration_hidden_fields
        {'plugin2' => 'Plugin 2'}
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    environment = Environment.default
    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)

    get :index

    assert_tag :tag => 'input', :attributes => {:id => 'create_enterprise_plugin1', :type => 'hidden', :value => 'Plugin 1'}
    assert_tag :tag => 'input', :attributes => {:id => 'create_enterprise_plugin2', :type => 'hidden', :value => 'Plugin 2'}
  end

  should 'display only templates of the current environment' do
    env2 = fast_create(Environment)

    template1 = fast_create(Enterprise, :name => 'template1', :environment_id => Environment.default.id, :is_template => true)
    template2 = fast_create(Enterprise, :name => 'template2', :environment_id => Environment.default.id, :is_template => true)
    template3 = fast_create(Enterprise, :name => 'template3', :environment_id => env2.id, :is_template => true)

    get :index

    assert_select '#template-options' do |elements|
      assert_match /template1/, elements[0].to_s
      assert_match /template2/, elements[0].to_s
      assert_no_match /template3/, elements[0].to_s
    end
  end

end
