require File.dirname(__FILE__) + '/../test_helper'
require 'admin_panel_controller'

# Re-raise errors caught by the controller.
class AdminPanelController; def rescue_action(e) raise e end; end

class AdminPanelControllerTest < Test::Unit::TestCase

  all_fixtures
  def setup
    @controller = AdminPanelController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(:ze)
  end

  def test_index
    get :index
    assert_template 'index'
    assert_tag :tag => 'a', :attributes => { :href => /categories/ }
    assert_tag :tag => 'a', :attributes => { :href => /edit_template/ }
    assert_tag :tag => 'a', :attributes => { :href => /features/ }
    assert_tag :tag => 'a', :attributes => { :href => /role/ }
  end
end
