require "#{File.dirname(__FILE__)}/../test_helper"

class RoutingTest < ActionController::IntegrationTest

  def test_homepage
    assert_routing('/', :controller => 'home', :action => 'index')
  end

  def test_doc_controller
    #FIXME: assert_routing cannot find controllers in plugins'
    flunk 'FIXME: assert_routing cannot find controllers in plugins'
    assert_routing('/doc', :controller => 'doc', :action => 'index')
  end

  def test_account_controller
    assert_routing('/account', :controller => 'account', :action => 'index')
  end

  def test_comatose_admin
    #FIXME: assert_routing cannot find controllers in plugins'
    flunk 'FIXME: assert_routing cannot find controllers in plugins'
    assert_routing('/cms/ze', :controller => 'comatose_admin')
  end

  def test_features_controller
    assert_routing('/admin/features', :controller => 'features', :action => 'index')
  end

  def test_content_viewer

    # profile root:
    assert_routing('/ze', :controller => 'content_viewer', :action => 'view_page', :profile => 'ze', :page => [])

    # some non-root page
    assert_routing('/ze/work/2007', :controller => 'content_viewer', :action => 'view_page', :profile => 'ze', :page => ['work', "2007"])
  end

end
