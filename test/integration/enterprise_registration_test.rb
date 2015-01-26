require_relative "../test_helper"

class EnterpriseRegistrationTest < ActionController::IntegrationTest

  fixtures :users, :profiles, :environments

  should 'be able to create an enterprise registration request' do

    environment = Environment.default
    environment.organization_approval_method = :region
    environment.save
    region1 = environment.regions.build(:name => 'A region')
    region1.save!
    region2 = environment.regions.build(:name => 'Other region')
    region2.save!
    org = Organization.create!(:name => "My organization", :identifier => 'myorg')
    region1.validators << org

    login('ze', 'test')

    get '/enterprise_registration'
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => '/enterprise_registration', :method => 'post' }, :descendant => { :tag => 'input', :attributes => { :type => 'text', :name => 'create_enterprise[identifier]'} }

    data = {
      :name => 'My new enterprise',
      :identifier => 'mynewenterprise',
      :address => 'satan street, 666',
      :contact_phone => '1298372198',
      :contact_person => 'random joe',
      :legal_form => 'cooperative',
      :economic_activity => 'free software',
      :region_id => region1.id,
    }

    post '/enterprise_registration', :create_enterprise => data
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => '/enterprise_registration', :method => 'post' }, :descendant => { :tag => 'input', :attributes => { :type => 'radio', :name => 'create_enterprise[target_id]', :value => org.id } }

    assert_difference 'CreateEnterprise.count' do
      post '/enterprise_registration', :create_enterprise => data.merge(:target_id => org.id)
    end
    
    assert_template 'confirmation'
    assert_tag :tag => 'a', :attributes => { :href => '/' }

    code = CreateEnterprise.find(:first, :order => 'id desc').code

    post '/account/logout'

    # steps done by the validator
    validator = create_user_with_permission('validator', 'validate_enterprise', org)
    validator.user.activate
    login 'validator', 'validator'

    get "/myprofile/myorg/enterprise_validation"
    assert_response :success
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/myorg/enterprise_validation/details/#{code}" }

    get "/myprofile/myorg/enterprise_validation/details/#{code}"
    assert_response :success
    assert_tag :form, :attributes => { :action => "/myprofile/myorg/enterprise_validation/approve/#{code}" }

    post "/myprofile/myorg/enterprise_validation/approve/#{code}"
    assert_response :redirect
    
    follow_redirect!
    assert_equal "/myprofile/myorg/enterprise_validation/view_processed/#{code}", path
    assert_tag :span, :attributes =>  { :class => 'validation_approved' }
  end

end
