require 'test_helper'
require 'content_viewer_controller'

class ContentViewerControllerTest < ActionController::TestCase

  def setup
    @controller = ContentViewerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @environment = Environment.default
    @environment.enabled_plugins += ['AnalyticsPlugin']
    @environment.save!

    @user = create_user('testinguser').person
    login_as @user.identifier

    @community = build Community, identifier: 'testcomm', name: 'test'
    @community.analytics_settings.enabled = true
    @community.analytics_settings.anonymous = false
    @community.save!
    @community.add_member @user
  end

  should 'register page view correctly' do
    @request.env['HTTP_REFERER'] = 'http://google.com'
    first_url = 'http://test.host/testcomm'
    get :view_page, profile: @community.identifier, page: []
    assert_equal 1, @community.page_views.count
    assert_equal 1, @community.visits.count

    first_page_view = @community.page_views.order(:id).first
    assert_equal @request.referer, first_page_view.referer_url

    @request.env['HTTP_REFERER'] = first_url
    get :view_page, profile: @community.identifier, page: @community.articles.last.path.split('/')
    assert_equal 2, @community.page_views.count
    assert_equal 1, @community.visits.count

    second_page_view = @community.page_views.order(:id).last
    assert_equal first_page_view, second_page_view.referer_page_view

    assert_equal @user, second_page_view.user

    assert second_page_view.request_duration > 0 and second_page_view.request_duration < 1
  end

end
