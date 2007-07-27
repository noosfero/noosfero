require "#{File.dirname(__FILE__)}/../test_helper"

class RoutingTest < ActionController::IntegrationTest

  def test_features_controller
    assert_routing('/admin/features', :controller => 'features', :action => 'index')
  end

  def test_account_controller
    assert_routing('/account', :controller => 'account', :action => 'index')
  end

  def test_content_viewer_controller_for_profile_root
    assert_routing('/ze', :controller => 'content_viewer', :action => 'view_page', :profile => 'ze', :page => [])
  end

  def test_content_viewer_controller_for_page_inside_profile
    assert_routing('/ze/work/2007', :controller => 'content_viewer', :action => 'view_page', :profile => 'ze', :page => ['work', "2007"])
  end

end
