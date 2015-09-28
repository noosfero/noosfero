require_relative '../../../../test/test_helper'
require_relative '../../controllers/comment_paragraph_plugin_admin_controller'

# Re-raise errors caught by the controller.
class CommentParagraphPluginAdminController; def rescue_action(e) raise e end; end

class CommentParagraphPluginAdminControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    user_login = create_admin_user(@environment)
    login_as(user_login)
    @environment.enabled_plugins = ['CommentParagraphPlugin']
    @environment.save!
    @plugin_settings = Noosfero::Plugin::Settings.new(@environment, CommentParagraphPlugin)
  end
  attr_reader :plugin_settings, :environment

  should 'access index action' do
    get :index
    assert_response :success
  end

  should 'update comment paragraph plugin settings' do
    assert_not_equal 'auto', plugin_settings.get_setting(:activation_mode)
    post :index, :settings => { :activation_mode => 'auto' }
    environment.reload
    assert_equal 'auto', plugin_settings.get_setting(:activation_mode)
  end

  should 'get article types previously selected' do
    plugin_settings.activation_mode = 'manual'
    plugin_settings.save!
    get :index
    assert_tag :input, :attributes => { :value => 'manual', :checked => 'checked' }
  end

end
