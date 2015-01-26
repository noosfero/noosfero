require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../controllers/vote_plugin_admin_controller'

# Re-raise errors caught by the controller.
class VotePluginAdminController; def rescue_action(e) raise e end; end

class VotePluginAdminControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    @profile = create_user_with_permission('profile', 'edit_environment_features', Environment.default)
    login_as(@profile.identifier)
  end

  attr_reader :environment

  should 'save vote_plugin settings' do
    post :index, :settings => {"enable_vote_article" => [1], "enable_vote_comment" => [-1]}
    @settings = Noosfero::Plugin::Settings.new(environment.reload, VotePlugin)
    assert_equal [1], @settings.settings[:enable_vote_article]
    assert_equal [-1], @settings.settings[:enable_vote_comment]
    assert_redirected_to :action => 'index'
  end

  should 'redirect to index after save' do
    post :index, :settings => {"enable_vote_article" => [1]}
    assert_redirected_to :action => 'index'
  end

end
