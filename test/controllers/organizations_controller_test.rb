require_relative "../test_helper"

class OrganizationsControllerTest < ActionController::TestCase
  def setup
    @controller = OrganizationsController.new

    @environment = Environment.default

    admin_user = create_admin_user(@environment)
    give_permission(admin_user, "manage_environment_organizations", @environment)
    login_as(admin_user)
  end
  attr_accessor :environment

  should "not access without right permission" do
    create_user("guest")
    login_as "guest"
    get :index
    assert_response 403 # forbidden
  end

  should "grant access with right permission" do
    get :index
    assert_response :success
  end

  should "show list to deactivate organizations" do
    enabled_community = fast_create(Community, environment_id: Environment.default, name: "enabled community")
    disabled_community = fast_create(Community, environment_id: Environment.default, name: "disabled community")
    disabled_community.disable

    get :index, filter: "enabled"

    assert_match(/enabled community/, @response.body)
    assert_no_match(/disabled community/, @response.body)
  end

  should "show list to activate organizations" do
    enabled_community = fast_create(Community, environment_id: Environment.default, name: "enabled community")
    disabled_community = fast_create(Community, environment_id: Environment.default, name: "disabled community")
    disabled_community.disable

    get :index, filter: "disabled"

    assert_no_match(/enabled community/, @response.body)
    assert_match(/disabled community/, @response.body)
  end

  should "show list only of enterprises" do
    community = fast_create(Community, environment_id: Environment.default, name: "Community Test")
    enterprise = fast_create(Enterprise, environment_id: Environment.default, name: "Enterprise Test")

    get :index, type: "Enterprise"

    assert_match(/Enterprise Test/, @response.body)
    assert_no_match(/Community Test/, @response.body)
  end

  should "show list only of communities" do
    community = fast_create(Community, environment_id: Environment.default, name: "Community Test")
    enterprise = fast_create(Enterprise, environment_id: Environment.default, name: "Enterprise Test")

    get :index, type: "Community"

    assert_no_match(/Enterprise Test/, @response.body)
    assert_match(/Community Test/, @response.body)
  end

  should "show list all organizations" do
    community = fast_create(Community, environment_id: Environment.default, name: "Community Test")
    enterprise = fast_create(Enterprise, environment_id: Environment.default, name: "Enterprise Test")

    get :index, type: "any"

    assert_match(/Enterprise Test/, @response.body)
    assert_match(/Community Test/, @response.body)
  end

  should "show custom organization type filter through hotspot" do
    fast_create(Community, environment_id: Environment.default, name: "Community Test")

    class GreatPlugin < Noosfero::Plugin
      def organization_types_filter_options
        [["TotallyDifferentName", "GreatPlugin::GreatOrganization"]]
      end
    end

    class GreatPlugin::GreatOrganization < Organization
    end

    Noosfero::Plugin.stubs(:all).returns(["OrganizationsControllerTest::GreatPlugin"])
    environment.enable_plugin(GreatPlugin)

    GreatPlugin::GreatOrganization.create!(name: "Great", identifier: "great")

    get :index, type: "any"

    assert_tag :option, attributes: { value: "GreatPlugin::GreatOrganization" }, content: "TotallyDifferentName"

    assert_match(/Great/, @response.body)
    assert_match(/Community Test/, @response.body)

    get :index, type: "GreatPlugin::GreatOrganization"

    assert_match(/Great/, @response.body)
    assert_no_match(/Community Test/, @response.body)
  end

  should "activate organization profile" do
    organization = fast_create(Organization, visible: false, environment_id: environment.id)
    refute organization.visible?

    get :activate, id: organization.id
    organization.reload

    assert organization.visible
  end

  should "deactivate organization profile" do
    organization = fast_create(Organization, visible: true, environment_id: environment.id)
    assert organization.visible

    get :deactivate, id: organization.id
    organization.reload

    refute organization.visible
  end

  should "destroy organization profile" do
    organization = fast_create(Organization, environment_id: environment.id)

    post :destroy, id: organization.id

    assert_raise ActiveRecord::RecordNotFound do
      organization.reload
    end
  end
end
