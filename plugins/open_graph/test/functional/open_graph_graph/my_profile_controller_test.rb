require 'test_helper'
require 'open_graph_plugin/myprofile_controller'

# Re-raise errors caught by the controller.
class OpenGraphPlugin::MyprofileController; def rescue_action(e) raise e end; end

class OpenGraphPlugin::MyprofileControllerTest < ActionController::TestCase

  def setup
    @controller = OpenGraphPlugin::MyprofileController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @actor = create_user.person
  end

  should "save selected activities" do
    login_as @actor.identifier
    @myenterprise = @actor.environment.enterprises.create! name: 'mycoop', identifier: 'mycoop'
    @myenterprise.add_member @actor
    @enterprise = @actor.environment.enterprises.create! name: 'coop', identifier: 'coop'
    @enterprise.fans << @actor

    post :track_config, profile: @actor.identifier, profile_data: {
      open_graph_settings: {
        activity_track_enabled: "true",
        enterprise_track_enabled: "true",
        community_track_enabled: "false",
      },
      open_graph_activity_track_configs_attributes: {
        0 => {
          tracker_id: @actor.id,
          object_type: 'blog_post',
        },
      },

      # ignored, enterprise uses static tracking
      open_graph_enterprise_profiles_ids: [@enterprise.id],
    }
    @actor.reload

    assert_equal true, @actor.open_graph_settings.activity_track_enabled
    assert_equal true, @actor.open_graph_settings.enterprise_track_enabled
    assert_equal false, @actor.open_graph_settings.community_track_enabled

    assert_equal 1, @actor.open_graph_activity_track_configs.count
    assert_equal 'blog_post', @actor.open_graph_activity_track_configs.first.object_type
    assert_equal @actor.id, @actor.open_graph_activity_track_configs.first.tracker_id

    assert_equal [@actor], OpenGraphPlugin::EnterpriseTrackConfig.trackers_to_profile(@enterprise)
    assert_equal [@actor], OpenGraphPlugin::EnterpriseTrackConfig.trackers_to_profile(@myenterprise)

  end

end
