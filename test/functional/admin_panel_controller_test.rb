require File.dirname(__FILE__) + '/../test_helper'
require 'admin_panel_controller'

# Re-raise errors caught by the controller.
class AdminPanelController; def rescue_action(e) raise e end; end

class AdminPanelControllerTest < Test::Unit::TestCase

  fixtures :environments

  def setup
    @controller = AdminPanelController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_template 'index'
    assert_tag :tag => 'a', :attributes => { :href => /manage_tags/ }
    assert_tag :tag => 'a', :attributes => { :href => /edit_template/ }
    assert_tag :tag => 'a', :attributes => { :href => /features/ }
  end
end
