require "test_helper"

# Re-raise errors caught by the controller.
class OrganizationRatingsPluginProfileController; def rescue_action(e) raise e end; end

class OrganizationRatingsPluginProfileControllerTest < ActionController::TestCase
  def setup
    @controller = OrganizationRatingsPluginProfileController.new

    @environment = Environment.default
    @environment.enabled_plugins = ["OrganizationRatingsPlugin"]
    @environment.save

    @person = create_user("testuser").person
    @community = Community.create(name: "TestCommunity")
    @community.add_admin @person
    @enterprise = fast_create(Enterprise)
    @config = OrganizationRatingsConfig.instance
    login_as(@person.identifier)
    @controller.stubs(:logged_in?).returns(true)
    @controller.stubs(:current_user).returns(@person.user)
  end

  test "should add new comment to community" do
    post :new_rating, profile: @community.identifier, comments: { body: "This is a test" }, organization_rating_value: 4
    assert_equal "#{@community.name} successfully rated!", session[:notice]
  end

  test "should redirect to profile home page" do
    @community.home_page = @community.blog
    @community.save
    post :new_rating, profile: @community.identifier, comments: { body: "This is minor a test" }, organization_rating_value: 3
    assert_redirected_to @community.url
  end

  test "create community_rating without comment body" do
    post :new_rating, profile: @community.identifier, comments: { body: "" }, organization_rating_value: 2

    assert_equal "#{@community.name} successfully rated!", session[:notice]
  end

  test "do not create community_rating without a rate value" do
    post :new_rating, profile: @community.identifier, comments: { body: "" }, organization_rating_value: nil

    assert_tag tag: "div", attributes: { class: /errorExplanation/ }, content: /Value can't be blank/
  end

  test "do not create two ratings on Community when vote once config is true" do
    post :new_rating, profile: @community.identifier, comments: { body: "This is a test" }, organization_rating_value: 3

    assert_equal "#{@community.name} successfully rated!", session[:notice]

    @environment.organization_ratings_config.vote_once = true
    @environment.save

    post :new_rating, profile: @community.identifier, comments: { body: "This is a test 2" }, organization_rating_value: 3
    assert_equal "You can not vote on this Community", session[:notice]
  end

  test "do not create two ratings on Enterprise when vote once config is true" do
    post :new_rating, profile: @enterprise.identifier, comments: { body: "This is a test" }, organization_rating_value: 3

    assert_equal "#{@enterprise.name} successfully rated!", session[:notice]

    @environment.organization_ratings_config.vote_once = true
    @environment.save

    post :new_rating, profile: @enterprise.identifier, comments: { body: "This is a test 2" }, organization_rating_value: 3
    assert_equal "You can not vote on this Enterprise", session[:notice]
  end

  test "should count organization ratings on statistic block when block owner = Environment" do
    block = StatisticsBlock.new
    enterprise = fast_create(Enterprise)
    post :new_rating, profile: enterprise.identifier, comments: { body: "body board" }, organization_rating_value: 1
    CreateOrganizationRatingComment.last.finish
    enterprise.reload
    @environment.reload
    block.expects(:owner).at_least_once.returns(@environment)
    assert_equal 1, block.comments
  end

  test "should count organization ratings on statistic block when block owner = Profile" do
    @config.cooldown = 0
    @config.save

    block = StatisticsBlock.new

    post :new_rating, profile: @community.identifier, comments: { body: "body board" }, organization_rating_value: 1
    post :new_rating, profile: @community.identifier, comments: { body: "body surf" }, organization_rating_value: 5
    CreateOrganizationRatingComment.all.each do |s|
      s.finish
    end
    block.expects(:owner).at_least_once.returns(@community)
    @community.reload
    assert_equal 2, block.comments
  end

  test "display unavailable rating message for users that must wait the rating cooldown time" do
    post :new_rating, profile: @community.identifier, comments: { body: "" }, organization_rating_value: 3
    assert_no_match(/The administrators set the minimum time of/, @response.body)
    valid_rating = OrganizationRating.last

    post :new_rating, profile: @community.identifier, comments: { body: "" }, organization_rating_value: 3
    assert_match(/The administrators set the minimum time of/, @response.body)
    new_rating = OrganizationRating.last

    assert_equal valid_rating.id, new_rating.id
  end

  test "display moderation report message body to community admin" do
    @member = create_user("member")
    @community.add_member @member.person
    login_as "member"
    @controller.stubs(:current_user).returns(@member)

    post :new_rating, profile: @community.identifier, comments: { body: "comment" }, organization_rating_value: 3

    login_as "testuser"
    @controller.stubs(:current_user).returns(@person.user)
    get :new_rating, profile: @community.identifier
    assert_tag tag: "p", content: /Report waiting for approval/, attributes: { class: /moderation-msg/ }
    !assert_tag tag: "p", attributes: { class: /comment-body/ }
  end

  test "display moderation report message to owner" do
    @member = create_user("member")
    @community.add_member @member.person
    login_as "member"
    @controller.stubs(:current_user).returns(@member)

    post :new_rating, profile: @community.identifier, comments: { body: "comment" }, organization_rating_value: 3
    get :new_rating, profile: @community.identifier
    assert_tag tag: "p", content: /Report waiting for approval/, attributes: { class: /moderation-msg/ }
    !assert_tag tag: "p", attributes: { class: /comment-body/ }
  end

  test "display moderation report message comment to env admin" do
    post :new_rating, profile: @community.identifier, comments: { body: "comment" }, organization_rating_value: 3

    @admin = create_admin_user(@environment)
    login_as @admin
    @controller.stubs(:current_user).returns(Profile[@admin].user)

    get :new_rating, profile: @community.identifier
    assert_tag tag: "p", content: /Report waiting for approval/, attributes: { class: /moderation-msg/ }
    assert_tag tag: "p", attributes: { class: /comment-body/ }
  end

  test "display rejected comment to env admin" do
    post :new_rating, profile: @community.identifier, comments: { body: "rejected comment" }, organization_rating_value: 3

    @admin = create_admin_user(@environment)
    login_as @admin
    @controller.stubs(:current_user).returns(Profile[@admin].user)

    CreateOrganizationRatingComment.last.cancel

    get :new_rating, profile: @community.identifier
    assert_tag tag: "p", attributes: { class: /comment-body/ }, content: /rejected comment/
  end

  test "not display rejected comment to regular user" do
    p1 = create_user("regularUser").person
    @community.add_member p1
    login_as(p1.identifier)
    @controller.stubs(:logged_in?).returns(true)
    @controller.stubs(:current_user).returns(p1.user)

    post :new_rating, profile: @community.identifier, comments: { body: "rejected comment" }, organization_rating_value: 3
    CreateOrganizationRatingComment.last.cancel
    get :new_rating, profile: @community.identifier
    !assert_tag tag: "p", attributes: { class: /comment-body/ }
  end

  test "not display rejected comment to community admin" do
    post :new_rating, profile: @community.identifier, comments: { body: "rejected comment" }, organization_rating_value: 3
    CreateOrganizationRatingComment.last.cancel
    get :new_rating, profile: @community.identifier
    !assert_tag tag: "p", attributes: { class: /comment-body/ }
  end

  test "not display moderation report message to regular user" do
    post :new_rating, profile: @community.identifier, comments: { body: "comment" }, organization_rating_value: 3
    rating_task = CreateOrganizationRatingComment.last
    rating_task.cancel

    @member = create_user("member")
    @community.add_member @member.person
    login_as "member"
    @controller.stubs(:current_user).returns(@member)

    get :new_rating, profile: @community.identifier
    !assert_tag tag: "p", content: /Report waiting for approval/, attributes: { class: /moderation-msg/ }
    !assert_tag tag: "p", attributes: { class: /comment-body/ }
  end

  test "not display rejected comment message to not logged user" do
    post :new_rating, profile: @community.identifier, comments: { body: "comment" }, organization_rating_value: 3
    rating_task = CreateOrganizationRatingComment.last
    rating_task.cancel

    logout
    @controller.stubs(:logged_in?).returns(false)

    get :new_rating, profile: @community.identifier
    !assert_tag tag: "p", content: /Report waiting for approval/, attributes: { class: /comment-rejected-msg/ }
    !assert_tag tag: "p", attributes: { class: /comment-body/ }
  end

  test "display report when Task accepted" do
    post :new_rating, profile: @community.identifier, comments: { body: "comment accepted" }, organization_rating_value: 3
    rating_task = CreateOrganizationRatingComment.last
    rating_task.finish

    get :new_rating, profile: @community.identifier
    !assert_tag tag: "p", content: /Report waiting for approva/, attributes: { class: /comment-rejected-msg/ }
    assert_tag tag: "p", content: /comment accepted/, attributes: { class: /comment-body/ }
  end

  test "should display ratings count in average block" do
    average_block = AverageRatingBlock.new
    average_block.box = @community.boxes.find_by_position(1)
    average_block.save!

    OrganizationRating.stubs(:statistics_for_profile).returns(average: 5, total: 42)
    get :new_rating, profile: @community.identifier
    assert_tag tag: "a", content: /\(42\)/
  end

  test "should display maximum ratings count in average block" do
    average_block = AverageRatingBlock.new
    average_block.box = @community.boxes.find_by_position(1)
    average_block.save!

    OrganizationRating.stubs(:statistics_for_profile).returns(average: 5, total: 999000)
    get :new_rating, profile: @community.identifier
    assert_tag tag: "a", content: /\(10000\+\)/
  end
end
