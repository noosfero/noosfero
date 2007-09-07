require "#{File.dirname(__FILE__)}/../test_helper"

class RoutingTest < ActionController::IntegrationTest

  # home page
  ################################################################
  def test_homepage
    assert_routing('/', :controller => 'home', :action => 'index')
  end

  # auxiliary (development) controllers
  ################################################################
  def test_doc_controller
    require File.join(RAILS_ROOT, 'vendor', 'plugins', 'doc_browser', 'controllers', 'doc_controller')
    assert_routing('/doc', :controller => 'doc', :action => 'index')
  end

  # user-targeted controllers (account/*, cms/*, customize/*)
  ################################################################
  def test_account_controller
    assert_routing('/account', :controller => 'account', :action => 'index')
  end

  def test_comatose_admin
    assert_routing('/cms/ze', :profile => 'ze', :controller => 'cms', :action => 'index')
  end

  def test_edit_template
    assert_routing('/admin/edit_template', :controller => 'edit_template', :action => 'index')
  end

  # virtual community administrative controllers (admin/*)
  ################################################################

  def test_admin_panel_controller
    assert_routing('/admin', :controller => 'admin_panel', :action => 'index')
  end

  def test_features_controller
    assert_routing('/admin/features', :controller => 'features', :action => 'index')
    assert_routing('/admin/features/update', :controller => 'features', :action => 'update')
  end

  def test_manage_tags_controller
    assert_routing('/admin/manage_tags', :controller => 'manage_tags', :action => 'index')
  end

  # platform administrative controllers (metaadmin/*)
  ################################################################

  # external public controllers
  ################################################################
  def test_content_viewer

    # profile root:
    assert_routing('/ze', :controller => 'content_viewer', :action => 'view_page', :profile => 'ze', :page => [])

    # some non-root page
    assert_routing('/ze/work/2007', :controller => 'content_viewer', :action => 'view_page', :profile => 'ze', :page => ['work', "2007"])
  end

end
