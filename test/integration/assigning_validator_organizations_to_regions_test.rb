require_relative "../test_helper"

class AssigningValidatorOrganizationsToRegionsTest < ActionDispatch::IntegrationTest

  should 'be able to properly assign organizations as validators to regions' do
    env = Environment.default

    Organization.destroy_all
    org1 = Organization.create!(:name => 'Organization one', :identifier => 'org1')
    org2 = Organization.create!(:name => 'Organization two', :identifier => 'org2')

    Region.destroy_all
    region1 = create(Region, :name => "Region 1", :environment_id => env.id)
    region2 = create(Region, :name => "Region 2", :environment_id => env.id)

    login('ze', 'test')

    get '/admin/region_validators'
    assert_response :success

    get "/admin/region_validators/region/#{region1.id}"
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => "/admin/region_validators/region/#{region1.id}" }, :descendant => { :tag => 'input', :attributes => { :type => 'text', :name => 'search' } }

    get "/admin/region_validators/region/#{region1.id}", :search => 'two'
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => "/admin/region_validators/add/#{region1.id}" }, :descendant => { :tag => 'input', :attributes => { :type => 'hidden', :name => 'validator_id', :value => org2.id } }

    post "/admin/region_validators/add/#{region1.id}", :validator_id => org2.id
    assert_response :redirect

    follow_redirect!
    assert_equal "/admin/region_validators/region/#{region1.id}", path

    assert_tag :tag => 'a', :attributes => { :href => "/admin/region_validators/remove/#{region1.id}?validator_id=#{org2.id}" }

    post "/admin/region_validators/remove/#{region1.id}", :validator_id => org2.id
    assert_response :redirect

    follow_redirect!
    assert_equal "/admin/region_validators/region/#{region1.id}", path
    assert_no_tag :tag => 'a', :attributes => { :href => "/admin/region_validators/remove/#{region1.id}?validator_id=#{org2.id}" }

  end
end
