require_relative "../test_helper"
require 'organizations_controller'

# Re-raise errors caught by the controller.
class OrganizationsController; def rescue_action(e) raise e end; end

class OrganizationsControllerTest < ActionController::TestCase

  def setup
    @controller = OrganizationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Environment.destroy_all
    @environment = fast_create(Environment, :is_default => true)

    admin_user = create_user_with_permission('adminuser', 'manage_environment_organizations', environment)
    login_as('adminuser')
  end

  attr_accessor :environment

  should 'not access without right permission' do
    create_user('guest')
    login_as 'guest'
    get :index
    assert_response 403 # forbidden
  end

  should 'grant access with right permission' do
    get :index
    assert_response :success
  end

  should 'show list to deactivate organizations' do
    enabled_community = fast_create(Community, :environment_id => Environment.default, :name=>"enabled community")
    disabled_community = fast_create(Community, :environment_id => Environment.default, :name=>"disabled community")
    disabled_community.disable

    get :index, :filter => 'enabled'

    assert_match(/enabled community/, @response.body)
    assert_not_match(/disabled community/, @response.body)
  end

  should 'show list to activate organizations' do
    enabled_community = fast_create(Community, :environment_id => Environment.default, :name=>"enabled community")
    disabled_community = fast_create(Community, :environment_id => Environment.default, :name=>"disabled community")
    disabled_community.disable

    get :index, :filter => 'disabled'

    assert_not_match(/enabled community/, @response.body)
    assert_match(/disabled community/, @response.body)
  end

  should 'show list only of enterprises' do
    community = fast_create(Community, :environment_id => Environment.default, :name=>"Community Test")
    enterprise = fast_create(Enterprise, :environment_id => Environment.default, :name=>"Enterprise Test")

    get :index, :type => 'Enterprise'

    assert_match(/Enterprise Test/, @response.body)
    assert_not_match(/Community Test/, @response.body)
  end

  should 'show list only of communities' do
    community = fast_create(Community, :environment_id => Environment.default, :name=>"Community Test")
    enterprise = fast_create(Enterprise, :environment_id => Environment.default, :name=>"Enterprise Test")

    get :index, :type => 'Community'

    assert_not_match(/Enterprise Test/, @response.body)
    assert_match(/Community Test/, @response.body)
  end

  should 'show list all organizations' do
    community = fast_create(Community, :environment_id => Environment.default, :name=>"Community Test")
    enterprise = fast_create(Enterprise, :environment_id => Environment.default, :name=>"Enterprise Test")

    get :index, :type => 'any'

    assert_match(/Enterprise Test/, @response.body)
    assert_match(/Community Test/, @response.body)
  end

  should 'activate organization profile' do
    organization = fast_create(Organization, :visible => false, :environment_id => environment.id)
    assert !organization.visible?

    get :activate, {:id => organization.id}
    organization.reload

    assert organization.visible
  end

  should 'deactivate organization profile' do
    organization = fast_create(Organization, :visible => true, :environment_id => environment.id)
    assert organization.visible

    get :deactivate, {:id => organization.id}
    organization.reload

    assert !organization.visible
  end

  should 'destroy organization profile' do
    organization = fast_create(Organization, :environment_id => environment.id)

    post :destroy, {:id => organization.id}

    assert_raise ActiveRecord::RecordNotFound do
      organization.reload
    end
  end
end
