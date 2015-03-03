require_relative '../test_helper'
require_relative '../../controllers/people_block_plugin_profile_controller'


# Re-raise errors caught by the controller.
class PeopleBlockPluginProfileController; def rescue_action(e) raise e end; end

class PeopleBlockPluginProfileControllerTest < ActionController::TestCase

  def setup
    @controller = PeopleBlockPluginProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = fast_create(Community)

    @environment = @profile.environment
    @environment.enabled_plugins = ['PeopleBlockPlugin']
    @environment.save!

    MembersBlock.delete_all
    @block = MembersBlock.new
    @block.box = @profile.boxes.first
    @block.save!

    @admin = create_user('adminprofile').person
    @member = create_user('memberprofile').person
    @moderator = create_user('moderatorprofile').person
    @profile.add_moderator(@moderator)
    @profile.add_member(@member)
    @profile.add_admin(@admin)
  end

  attr_accessor :profile, :block, :admin, :member, :moderator

  should 'list members without role_key' do
    get :members, :profile => profile.identifier, :role_key => ""
    assert_response :success
    assert_template 'members'
    assert_equivalent [@admin, @member, @moderator], assigns(:members)
    assert_match /adminprofile/, @response.body
    assert_match /memberprofile/, @response.body
    assert_match /moderatorprofile/, @response.body
  end

  should 'list members with role_key=nil' do
    get :members, :profile => profile.identifier, :role_key => nil
    assert_response :success
    assert_template 'members'
    assert_equivalent [@admin, @member, @moderator], assigns(:members)
    assert_match /adminprofile/, @response.body
    assert_match /memberprofile/, @response.body
    assert_match /moderatorprofile/, @response.body
  end

  should 'list members only' do
    get :members, :profile => profile.identifier, :role_key => Profile::Roles.member(profile.environment.id).key
    assert_response :success
    assert_template 'members'
    assert_equal [@member], assigns(:members)
    assert_no_match /adminprofile/, @response.body
    assert_match /memberprofile/, @response.body
    assert_no_match /moderatorprofile/, @response.body
  end

  should 'list moderators only' do
    get :members, :profile => profile.identifier, :role_key => Profile::Roles.moderator(profile.environment.id).key
    assert_response :success
    assert_template 'members'
    assert_equal [@moderator], assigns(:members)
    assert_no_match /adminprofile/, @response.body
    assert_no_match /memberprofile/, @response.body
    assert_match /moderatorprofile/, @response.body
  end

end
