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

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  should 'link to site_info editing page' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/admin_panel/site_info' }
  end

  should 'link to cateogries editing' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/categories' }
  end

  should 'link to design editor' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/environment_design' }
  end

  should 'link to features editing screen' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/features' }
  end

  should 'link to role editing screen' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/role' }
  end

  should 'link to region validator screen' do
    get :index
    assert_tag :tag => 'a', :attributes => { :href => '/admin/region_validators' }
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
