require 'test_helper'
require_relative '../../controllers/sub_organizations_plugin_myprofile_controller'

# Re-raise errors caught by the controller.
class SubOrganizationsPluginMyprofileController; def rescue_action(e) raise e end; end

class SubOrganizationsPluginMyprofileControllerTest < ActionController::TestCase
  def setup
    @controller = SubOrganizationsPluginMyprofileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @organization = Organization.create!(:name => 'My Organization', :identifier => 'my-organization')
    @person = create_user('person').person
    @organization.add_admin(@person)
    login_as(@person.user.login)
    e = Environment.default
    e.enable_plugin('SubOrganizationsPlugin')
    e.save!
  end

  attr_accessor :person, :organization

  should 'search organizations' do
    # Should list if match name
    o1 = fast_create(Organization, :name => 'sample organization 1')
    # Should be case insensitive
    o2 = fast_create(Organization, :name => 'SaMpLe OrGaNiZaTiOn 2')
    # Should not list if don't match name
    o3 = fast_create(Organization, :name => 'blo')
    # Should not list if is has children
    child = fast_create(Organization)
    o4 = fast_create(Organization, :name => 'sample organization 4')
    SubOrganizationsPlugin::Relation.add_children(o4, child)
    # Should not list if is there is a task to add it
    o5 = fast_create(Organization, :name => 'sample enterprise 5')
    SubOrganizationsPlugin::ApprovePaternity.create!(:requestor => person, :target => o5, :temp_parent_id => organization.id, :temp_parent_type => organization.class.name)
    # Should search by identifier
    o6 = fast_create(Organization, :name => 'Bla', :identifier => 'sample-enterprise-6')
    # Should not list itself
    organization.name = 'Sample Organization'
    organization.save!

    get :search_organization, :profile => organization.identifier, :q => 'sampl'

    assert_match /#{o1.name}/, @response.body
    assert_match /#{o2.name}/, @response.body
    assert_no_match /#{o3.name}/, @response.body
    assert_no_match /#{o4.name}/, @response.body
    assert_no_match /#{o5.name}/, @response.body
    assert_match /#{o6.name}/, @response.body
    assert_no_match /#{organization.name}/, @response.body
  end

  should 'update sub-organizations list' do
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    org3 = fast_create(Organization)
    org4 = fast_create(Organization)
    SubOrganizationsPlugin::Relation.add_children(organization, org1, org2)

    post :index, :profile => organization.identifier, :q => [org2,org3,org4].map(&:id).join(',')

    children = Organization.children(organization)
    assert_not_includes children, org1
    assert_includes children, org2
    assert_not_includes children, org3
    assert_not_includes children, org4

    SubOrganizationsPlugin::ApprovePaternity.all.map(&:finish)

    children = Organization.children(organization)
    assert_not_includes children, org1
    assert_includes children, org2
    assert_includes children, org3
    assert_includes children, org4
  end

  should 'establish relation right away if the user can perform tasks on the sub-organization' do
    org1 = fast_create(Organization)
    org2 = fast_create(Organization)
    org2.add_admin(person)

    assert_difference 'SubOrganizationsPlugin::ApprovePaternity.count', 1 do
      post :index, :profile => organization.identifier, :q => [org1,org2].map(&:id).join(',')
    end
    assert_includes Organization.children(organization), org2
  end

  should 'not access index if dont have permission' do
    member = create_user('member').person
    organization.add_member(member)

    login_as(member.identifier)
    get :index, :profile => organization.identifier

    assert_response 403
    assert_template 'shared/access_denied'
  end

  should 'not search organizations if dont have permission' do
    member = create_user('member').person
    organization.add_member(member)

    login_as(member.identifier)

    org1 = fast_create(Organization, :name => 'sample organization 1')
    get :search_organization, :profile => organization.identifier, :q => 'sampl'

    assert_response 403
    assert_template 'shared/access_denied'
  end

end
