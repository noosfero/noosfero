require "#{File.dirname(__FILE__)}/../test_helper"

class EnterpriseRegistrationTest < ActionController::IntegrationTest

  fixtures :users, :profiles, :environments

  # Replace this with your real tests.
  should 'be able to create an enterprise registration request' do

    environment = Environment.default
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

    assert_difference CreateEnterprise, :count do
      post '/enterprise_registration', :create_enterprise => data.merge(:target_id => org.id)
    end
    
    assert_tag :tag => 'a', :attributes => { :href => '/' }

    # FIXME: add here
    # - the steps carried on by the validator organization to approve the registration
    # - the steps carried on by the requestor after that

  end

end
