require File.dirname(__FILE__) + '/../test_helper'
require 'content_viewer_controller'

# Re-raise errors caught by the controller.
class ContentViewerController; def rescue_action(e) raise e end; end

class ContentViewerControllerTest < Test::Unit::TestCase

  fixtures :domains, :environments, :users, :profiles, :comatose_pages

  def setup
    @controller = ContentViewerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_display_homepage
    uses_host 'anhetegua.net'

    a = Article.new
    Article.expects(:find_by_path).with('aprofile').returns(a)

    get :view_page, :profile => 'aprofile', :page => []
    assert_response :success
    assert_equal a, assigns(:page)
  end

  def test_should_get_not_found_error_for_unexisting_page
    uses_host 'anhetegua.net'
    get :view_page, :profile => 'ze', :page => ['some_unexisting_page']
    assert_response 404
  end

  def test_should_get_not_found_error_for_unexisting_profile
    Profile.delete_all
    uses_host 'anhetegua'
    get :view_page, :profile => 'some_unexisting_profile', :page => []
    assert_response 404
  end

end
