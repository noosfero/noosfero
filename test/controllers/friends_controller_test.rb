require_relative "../test_helper"

class FriendsControllerTest < ActionController::TestCase
  self.default_params = { profile: "testuser" }
  def setup
    @controller = FriendsController.new

    self.profile = create_user("testuser").person
    self.friend = create_user("thefriend").person
    login_as ("testuser")
  end
  attr_accessor :profile, :friend

  should "list friends in alphabetical order" do
    profile.add_friend(create_user("angela").person)
    profile.add_friend(create_user("paula").person)
    profile.add_friend(create_user("jose").person)

    get :index
    assert_response :success
    assert_template "index"
    assert_equal assigns(:friends).map(&:name), ["angela", "jose", "paula"]
  end

  should "only list friends of a person" do
    login_as :testuser
    community = fast_create(Community, name: "my test profile", identifier: "communitytest")
    enterprise = fast_create(Enterprise, name: "my test profile 2", identifier: "enterprisetest")
    community.add_admin(profile)
    enterprise.add_admin(profile)

    [community.identifier, enterprise.identifier].each do |id|
      get :index, profile: id
      assert_response :not_found
    end
  end

  should "confirm removal of friend" do
    profile.add_friend(friend)

    get :remove, id: friend.id
    assert_response :success
    assert_template "remove"
    ok("must load the friend being removed") { friend == assigns(:friend) }
  end

  should "actually remove friend" do
    profile.add_friend(friend)
    friend.add_friend(profile)

    assert_difference "Friendship.count", -2 do
      post :remove, id: friend.id, confirmation: "1"
      assert_redirected_to action: "index"
    end
  end

  should "display find people button" do
    get :index, profile: "testuser"
    assert_tag tag: "a", content: "Find people", attributes: { href: "/search/assets?asset=people".html_safe }
  end

  should "not display invite friends button if any plugin tells not to" do
    class Plugin1 < Noosfero::Plugin
      def remove_invite_friends_button
        true
      end
    end
    class Plugin2 < Noosfero::Plugin
      def remove_invite_friends_button
        false
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    e = profile.environment
    e.enable_plugin(Plugin1.name)
    e.enable_plugin(Plugin2.name)

    get :index, profile: "testuser"
    !assert_tag tag: "a", attributes: { href: "/profile/testuser/invite/friends" }
  end

  should "not display list suggestions button if there is no suggestion" do
    get :index, profile: "testuser"
    !assert_tag tag: "a", content: "Suggest friends", attributes: { href: "/myprofile/testuser/friends/suggest" }
  end

  should "display people suggestions" do
    profile.suggested_profiles.create(suggestion: friend)
    get :suggest, profile: "testuser"
    assert_tag tag: "a", content: "+ #{friend.name}", attributes: { href: "/profile/#{friend.identifier}/add" }
  end

  should "display button to add friend suggestion" do
    profile.suggested_profiles.create(suggestion: friend)
    get :suggest, profile: "testuser"
    assert_tag tag: "a", attributes: { href: "/profile/#{friend.identifier}/add" }
  end

  should "display button to remove people suggestion" do
    profile.suggested_profiles.create(suggestion: friend)
    get :suggest, profile: "testuser"
    assert_tag tag: "a", attributes: { href: /\/myprofile\/testuser\/friends\/remove_suggestion\/#{friend.identifier}/ }
  end

  should "remove suggestion of friend" do
    suggestion = profile.suggested_profiles.create(suggestion: friend)
    post :remove_suggestion, profile: "testuser", id: friend.identifier

    assert_response :success
    assert_equal false, ProfileSuggestion.find(suggestion.id).enabled
  end
end
