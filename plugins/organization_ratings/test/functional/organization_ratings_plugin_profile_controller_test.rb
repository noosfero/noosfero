require File.expand_path(File.dirname(__FILE__)) + '/../../../../test/test_helper'
require File.expand_path(File.dirname(__FILE__)) + '/../../controllers/organization_ratings_plugin_profile_controller'

# Re-raise errors caught by the controller.
class OrganizationRatingsPluginProfileController; def rescue_action(e) raise e end; end

class OrganizationRatingsPluginProfileControllerTest < ActionController::TestCase

  def setup
    @controller = OrganizationRatingsPluginProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @environment = Environment.default
    @environment.enabled_plugins = ['OrganizationRatingsPlugin']
    @environment.save

    @person = create_user('testuser').person
    @community = Community.create(:name => "TestCommunity")
    @enterprise = fast_create(Enterprise)
    @config = OrganizationRatingsConfig.instance
    login_as(@person.identifier)
    @controller.stubs(:logged_in?).returns(true)
    @controller.stubs(:current_user).returns(@person.user)
  end

  test "should add new comment to community" do
    post :new_rating, profile: @community.identifier, :comments => {:body => "This is a test"}, :organization_rating_value => 4
    assert_equal "#{@community.name} successfully rated!", session[:notice]
  end

  test "should redirect to profile home page" do
    @community.home_page = @community.blog
    @community.save
    post :new_rating, profile: @community.identifier, :comments => {:body => "This is minor a test"}, :organization_rating_value => 3
    assert_redirected_to @community.url
  end

  test "Create community_rating without comment body" do
    post :new_rating, profile: @community.identifier, :comments => {:body => ""}, :organization_rating_value => 2

    assert_equal "#{@community.name} successfully rated!", session[:notice]
  end

  test "Do not create community_rating without a rate value" do
    post :new_rating, profile: @community.identifier, :comments => {:body => ""}, :organization_rating_value => nil

    assert_equal "Sorry, there were problems rating this profile.", session[:notice]
  end

  test "do not create two ratings on Community when vote once config is true" do
    post :new_rating, profile: @community.identifier, :comments => {:body => "This is a test"}, :organization_rating_value => 3

    assert_equal "#{@community.name} successfully rated!", session[:notice]

    @environment.organization_ratings_config.vote_once = true
    @environment.save

    post :new_rating, profile: @community.identifier, :comments => {:body => "This is a test 2"}, :organization_rating_value => 3
    assert_equal "You can not vote on this Community", session[:notice]
  end

  test "do not create two ratings on Enterprise when vote once config is true" do
    post :new_rating, profile: @enterprise.identifier, :comments => {:body => "This is a test"}, :organization_rating_value => 3

    assert_equal "#{@enterprise.name} successfully rated!", session[:notice]

    @environment.organization_ratings_config.vote_once = true
    @environment.save

    post :new_rating, profile: @enterprise.identifier, :comments => {:body => "This is a test 2"}, :organization_rating_value => 3
    assert_equal "You can not vote on this Enterprise", session[:notice]
  end

  test "should count organization ratings on statistic block when block owner = Environment" do
    block = StatisticsBlock.new
    enterprise = fast_create(Enterprise)
    post :new_rating, profile: enterprise.identifier, :comments => {:body => "body board"}, :organization_rating_value => 1
    enterprise.reload
    @environment.reload
    block.expects(:owner).at_least_once.returns(@environment)
    assert_equal 1, block.comments
  end


  test "should count organization ratings on statistic block when block owner = Profile" do
    @config.cooldown = 0
    @config.save

    block = StatisticsBlock.new

    post :new_rating, profile: @community.identifier, :comments => {:body => "body board"}, :organization_rating_value => 1
    post :new_rating, profile: @community.identifier, :comments => {:body => "body surf"}, :organization_rating_value => 5

    block.expects(:owner).at_least_once.returns(@community)
    @community.reload
    assert_equal 2, block.comments
  end

  test "Display unavailable rating message for users that must wait the rating cooldown time" do
    post :new_rating, profile: @community.identifier, :comments => {:body => ""}, :organization_rating_value => 3
    assert_no_match(/The administrators set the minimum time of/, @response.body)
    valid_rating = OrganizationRating.last

    post :new_rating, profile: @community.identifier, :comments => {:body => ""}, :organization_rating_value => 3
    assert_match(/The administrators set the minimum time of/, @response.body)
    new_rating = OrganizationRating.last

    assert_equal valid_rating.id, new_rating.id
  end
end
