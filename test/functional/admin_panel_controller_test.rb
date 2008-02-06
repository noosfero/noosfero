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
    login_as(create_admin_user(Environment.default))
  end

  def test_index
    get :index
    assert_template 'index'
    assert_tag :tag => 'a', :attributes => { :href => /site_info/ }
    assert_tag :tag => 'a', :attributes => { :href => /categories/ }
    assert_tag :tag => 'a', :attributes => { :href => /edit_template/ }
    assert_tag :tag => 'a', :attributes => { :href => /features/ }
    assert_tag :tag => 'a', :attributes => { :href => /role/ }
    assert_tag :tag => 'a', :attributes => { :href => /region_validators/ }
  end
  
  should 'display form for editing site info' do
    get :site_info
    assert_template 'site_info'
    assert_tag :tag => 'textarea', :attributes => { :name => 'environment[description]'}
  end

  should 'save site description' do

    post :site_info, :environment => { :description => "This is my new environment" }
    assert_redirected_to :action => 'index'

    assert_equal "This is my new environment", Environment.default.description
  end

end
