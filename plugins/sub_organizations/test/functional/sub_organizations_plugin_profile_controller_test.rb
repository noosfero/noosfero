require 'test_helper'
require_relative '../../controllers/sub_organizations_plugin_profile_controller'

class SubOrganizationsPluginProfileControllerTest < ActionController::TestCase

  def setup
    @controller = SubOrganizationsPluginProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @organization = Organization.create!(:name => 'My Organization', :identifier => 'my-organization')
    @person = create_user('person').person
    @organization.add_admin(@person)
    login_as(@person.user.login)
    e = Environment.default
    e.enable_plugin('SubOrganizationsPlugin')
    e.save!
    @o1 = fast_create(Organization, :name => 'sample child organization 1')
    @o2 = fast_create(Community, :name => 'sample child community 1')
    @o3 = fast_create(Enterprise, :name => 'sample child enterprise 1')

    SubOrganizationsPlugin::Relation.add_children(@organization, @o2, @o3)
  end

  attr_accessor :person, :organization

  should 'display all children organizations' do
    get :children, :profile => @organization.identifier

    assert_no_match /#{@o1.name}/, @response.body
    assert_match /#{@o2.name}/, @response.body
    assert_match /#{@o3.name}/, @response.body
  end

  should 'display only communities' do
    get :children, :profile => @organization.identifier, :type => 'community'

    assert_no_match /#{@o1.name}/, @response.body
    assert_match /#{@o2.name}/, @response.body
    assert_no_match /#{@o3.name}/, @response.body
  end

  should 'display only enterprises' do
    get :children, :profile => @organization.identifier, :type => 'enterprise'

    assert_no_match /#{@o1.name}/, @response.body
    assert_no_match /#{@o2.name}/, @response.body
    assert_match /#{@o3.name}/, @response.body
  end

  should 'not respond to person profiles' do
    get :children, :profile => fast_create(Person, :name => 'Ze').identifier

    assert_response :missing
  end

end
