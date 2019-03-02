require 'test_helper'

class SiteTourPluginPublicControllerTest < ActionDispatch::IntegrationTest

  def setup
    @person = create_user('testuser').person
  end

  attr_accessor :person

  should 'not be able to mark an action if is not logged in' do
    post site_tour_plugin_public_path(:mark_action), params: {:action_name => 'test'}, xhr: true
    assert_response 401
  end

  should 'be able to mark one action' do
    login_as_rails5(person.identifier)
    post site_tour_plugin_public_path(:mark_action), params: { :action_name => 'test'}, xhr: true
    assert_equal({'ok' => true}, ActiveSupport::JSON.decode(response.body))
    assert_equal ['test'], person.reload.site_tour_plugin_actions
  end

  should 'be able to mark multiple actions' do
    login_as_rails5(person.identifier)
    post site_tour_plugin_public_path(:mark_action), params: {:action_name => ['test1', 'test2']}, xhr: true
    assert_equal({'ok' => true}, ActiveSupport::JSON.decode(response.body))
    assert_equal ['test1', 'test2'], person.reload.site_tour_plugin_actions
  end

end
