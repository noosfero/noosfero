require File.dirname(__FILE__) + '/../test_helper'
require 'content_viewer_controller'

# Re-raise errors caught by the controller.
class ContentViewerController; def rescue_action(e) raise e end; end

class ContentViewerControllerTest < Test::Unit::TestCase

  all_fixtures

  def setup
    @controller = ContentViewerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testinguser').person
  end
  attr_reader :profile

  def test_should_display_page
    page = profile.articles.build(:name => 'test')
    page.save!

    uses_host 'anhetegua.net'
    get :view_page, :profile => profile.identifier, :page => [ 'test' ]
    assert_response :success
    assert_equal page, assigns(:page)
  end

  def test_should_display_homepage
    flunk 'pending'
  end

  def test_should_display_something_else_for_empty_homepage
    flunk 'pending'
  end

  def test_should_get_not_found_error_for_unexisting_page
    uses_host 'anhetegua.net'
    get :view_page, :profile => 'aprofile', :page => ['some_unexisting_page']
    assert_response :missing
    # This is an idea of instead of give an error search for the term
#    assert_response :redirect
#    assert_redirected_to :controller => 'search', :action => 'index'
  end

  def test_should_get_not_found_error_for_unexisting_profile
    Profile.delete_all
    uses_host 'anhetegua'
    get :view_page, :profile => 'some_unexisting_profile', :page => []
    assert_response :missing    
    
    # This is an idea of instead of give an error search for the term
#    assert_response :redirect
#    assert_redirected_to :controller => 'search', :action => 'index'
  end

end
