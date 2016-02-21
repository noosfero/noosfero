require_relative "../test_helper"
require 'trusted_sites_controller'

class TrustedSitesControllerTest < ActionController::TestCase
  all_fixtures

  def setup
    @controller = TrustedSitesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @role = Role.first
    @environment = Environment.default
    @environment.trusted_sites_for_iframe = ['existing.site.com']
    @environment.save!

    login_as(:ze)
  end

  should 'get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:sites)
  end

  should 'get new' do
    get :new
    assert_response :success
  end

  should 'create site' do
    post :create, :site => 'new.site.com'
    assert_redirected_to :action => :index
    assert assigns(:environment).trusted_sites_for_iframe.include?('new.site.com'), 'Site was not included in the trusted_sites'
  end

  should 'fail creation gracefully' do
    @controller.stubs(:add_trusted_site).returns(false)
    post :create, :site => 'new.site.com'
    assert_response :success # it actually failed, but was not redirected
    refute assigns(:environment).trusted_sites_for_iframe.include?('new.site.com'), 'Site was included in the trusted_sites!?'
  end

  should 'destroy site' do
    post :create, :site => 'todel.site.com'
    delete :destroy, :site => 'todel.site.com'
    assert_redirected_to :action => :index
    refute  assigns(:environment).trusted_sites_for_iframe.include?('todel.site.com'), 'Site was not removed from trusted_sites'
  end

  should "get edit" do
    get :edit, :site => 'existing.site.com'
    assert_response :success
  end

  should "not get edit" do
    get :edit, :site => 'nonexistent.site.com'
    assert_redirected_to :action => :index
  end

  should 'update site' do
    post :create, :site => 'toedit.site.com'
    post :update, :orig_site => 'toedit.site.com', :site => 'edited.site.com'
    assert_redirected_to :action => :edit
    refute  assigns(:environment).trusted_sites_for_iframe.include?('toedit.site.com'), 'Original site found. Site was not updated?'
    assert assigns(:environment).trusted_sites_for_iframe.include?('edited.site.com'), 'New name for site not found. Site was not updated?'
  end

  should 'fail update gracefully' do
    @controller.stubs(:rename_trusted_site).returns(false)
    post :create, :site => 'toedit.site.com'
    post :update, :orig_site => 'toedit.site.com', :site => 'edited.site.com'
    assert_response :success # it actually failed, but was not redirected
    assert assigns(:environment).trusted_sites_for_iframe.include?('toedit.site.com'), 'Original site not found. Site was updated?'
    refute assigns(:environment).trusted_sites_for_iframe.include?('edited.site.com'), 'New name for site found. Site was updated?'
  end
end
