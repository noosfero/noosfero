require_relative "../test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  include MembershipsHelper

  def setup
    @profile = create_user("testuser").person
    @user = @profile.user
  end
  attr_reader :profile, :user

  should "list friends in alphabetical order" do
    profile.add_friend(create_user("angela").person)
    profile.add_friend(create_user("paula").person)
    profile.add_friend(create_user("jose").person)

    get friends_profile_path(profile.identifier)
    assert_response :success
    assert_template "friends"
    assert_equal assigns(:friends).map(&:name), ["angela", "jose", "paula"]
  end

  should "remove person from article followers when unfollow" do
    profile = create_user("testuser").person
    follower = create_user("follower").person
    article = profile.articles.create(name: "test")
    article.person_followers = [follower]
    article.save
    login_as_rails5("follower")
    article.reload
    assert_includes Article.find(article.id).person_followers, follower
    post unfollow_article_profile_path(profile.identifier), params: { article_id: article.id }
    assert_not_includes Article.find(article.id).person_followers, follower
  end

  should "point to manage friends in user is seeing his own friends" do
    login_as_rails5("testuser")
    get friends_profile_path(profile.identifier)
    assert_tag tag: "a", attributes: { href: "/myprofile/testuser/friends" }
  end

  should "not point to manage friends of other users" do
    create_user("ze")
    login_as_rails5("ze")
    get friends_profile_path(profile.identifier)
    !assert_tag tag: "a", attributes: { href: "/myprofile/testuser/friends" }
  end

  should "list communities" do
    get communities_profile_path(profile.identifier)

    assert_response :success
    assert_template "communities"
    assert assigns(:communities)
  end

  should "list enterprises" do
    get enterprises_profile_path(profile.identifier)

    assert_response :success
    assert_template "enterprises"
    assert assigns(:enterprises)
  end

  should "list members (for organizations)" do
    get members_profile_path(profile.identifier)

    assert_response :success
    assert_template "members"
    assert assigns(:profile_members)
    assert assigns(:profile_admins)
  end

  should "list favorite enterprises" do
    get favorite_enterprises_profile_path(profile.identifier)

    assert_response :success
    assert_template "favorite_enterprises"
    assert assigns(:favorite_enterprises)
  end

  should "not render any template when joining community due to Ajax request" do
    community = Community.create!(name: "my test community")
    login_as_rails5(@profile.identifier)

    get join_profile_path(community.identifier)
    assert_response :success
    assert_template nil
    !assert_tag tag: "html"
  end

  should "actually add friend" do
    login_as_rails5(@profile.identifier)
    person = create_user.person
    assert_difference "AddFriend.count" do
      post add_profile_path(person.identifier)
    end
  end

  should "not show enterprises link to enterprise" do
    ent = fast_create(Enterprise, identifier: "test_enterprise1", name: "Test enterprise1")
    get profile_path(profile.identifier)
    !assert_tag tag: "a", content: "Enterprises", attributes: { href: /profile\/#{ent.identifier}\/enterprises$/ }
  end

  should "not show members link to person" do
    person = create_user("person_1").person
    get profile_path(person.identifier)
    !assert_tag tag: "a", content: "Members", attributes: { href: /profile\/#{person.identifier}\/members$/ }
  end

  should "show friends link to person" do
    person = create_user("person_1").person
    person.add_friend(profile)
    get profile_path(person.identifier)
    assert_tag tag: "a", content: /#{person.friends.count}/, attributes: { href: /profile\/#{person.identifier}\/friends$/ }
  end

  should "display tag for profile" do
    @profile.articles.create!(name: "testarticle", tag_list: "tag1")

    get content_tagged_profile_path(@profile.identifier), params: { id: "tag1" }
    assert_tag tag: "a", attributes: { href: /testuser\/testarticle$/ }
  end

  should "link to the same tag but for whole environment" do
    @profile.articles.create!(name: "testarticle", tag_list: "tag1")
    get content_tagged_profile_path(@profile.identifier), params: { id: "tag1" }

    assert_tag tag: "a", attributes: { href: "/tag/tag1" }, content: 'See content tagged with "tag1" in the entire site'.html_safe
  end

  should "show a link to own control panel" do
    login_as_rails5(@profile.identifier)
    get profile_path(@profile.identifier)
    assert_tag tag: "a", content: "Control panel"
  end

  should "show a link to own control panel in my-network-block if is a group" do
    login_as_rails5(@profile.identifier)
    community = Community.create!(name: "my test community")
    community.blocks.each { |i| i.destroy }
    community.boxes[0].blocks << MyNetworkBlock.new
    community.add_admin(@profile)
    get profile_path(community.identifier)
    assert_tag tag: "a", content: "Control panel"
  end

  should "not show a link to others control panel" do
    login_as_rails5(@profile.identifier)
    other = create_user("person_1").person
    other.blocks.each { |i| i.destroy }
    other.boxes[0].blocks << ProfileInfoBlock.new
    get profile_path(other.identifier)
    !assert_tag tag: "ul", attributes: { class: "profile-info-data" }, descendant: { tag: "a", content: "Control panel" }
  end

  should "show a link to control panel if user has profile_editor permission and is a group" do
    login_as_rails5(@profile.identifier)
    community = Community.create!(name: "my test community")
    community.add_admin(@profile)
    get profile_path(community.identifier)
    assert_tag tag: "a", attributes: { href: /\/myprofile\/my-test-community/ }, content: "Control panel"
  end

  should "show create community in own profile" do
    login_as_rails5(@profile.identifier)
    get communities_profile_path(profile.identifier)
    assert_tag tag: "a", attributes: { class: "button icon-add with-text",
                                       title: "Create a new community" }
  end

  should "not show create community on profile of other users" do
    login_as_rails5(@profile.identifier)
    person = create_user("person_1").person
    get communities_profile_path(profile.identifier)
    !assert_tag tag: "a", child: { tag: "span", content: "Create a new community" }
  end

  should "not show Leave This Community button for non-registered users" do
    community = Community.create!(name: "my test community")
    community.boxes.first.blocks << block = ProfileInfoBlock.create!
    get profile_path(community.identifier)
    assert_no_match /\/profile\/#{@profile.identifier}\/leave/, @response.body
  end

  should "check access before displaying profile" do
    Person.any_instance.expects(:display_to?).with(anything).returns(false)
    @profile.visible = false
    @profile.save

    get profile_path(@profile.identifier)
    assert_response 403
  end

  should "display add friend button" do
    @profile.user.activate!
    login_as_rails5(@profile.identifier)
    friend = create_user_full("friendtestuser").person
    friend.user.activate!
    friend.boxes.first.blocks << block = ProfileInfoBlock.create!
    get profile_path(friend.identifier)
    assert_match /Add friend/, @response.body
  end

  should "not display add friend button if user already request friendship" do
    login_as_rails5(@profile.identifier)
    friend = create_user_full("friendtestuser").person
    friend.boxes.first.blocks << block = ProfileInfoBlock.create!
    AddFriend.create!(person: @profile, friend: friend)
    get profile_path(friend.identifier)
    assert_no_match /Add friend/, @response.body
  end

  should "not display add friend button if user already friend" do
    login_as_rails5(@profile.identifier)
    friend = create_user_full("friendtestuser").person
    friend.boxes.first.blocks << block = ProfileInfoBlock.create!
    @profile.add_friend(friend)
    @profile.friends.reload
    assert @profile.is_a_friend?(friend)
    get profile_path(friend.identifier)
    assert_no_match /Add friend/, @response.body
  end

  should "list top level articles in sitemap" do
    get sitemap_profile_path("testuser")
    assert_equal @profile.top_level_articles, assigns(:articles)
  end

  should "list tags" do
    Person.any_instance.stubs(:article_tags).returns("one" => 1, "two" => 2)
    get tags_profile_path("testuser")

    assert_tag tag: "div", attributes: { class: /main-block/ }, descendant: { tag: "a", attributes: { href: "/profile/testuser/tags/one" } }
    assert_tag tag: "div", attributes: { class: /main-block/ }, descendant: { tag: "a", attributes: { href: "/profile/testuser/tags/two" } }
  end

  should "not show e-mail for non friends on profile page" do
    p1 = create_user("tusr1").person
    p2 = create_user("tusr2", email: "t2@t2.com").person
    login_as_rails5 "tusr1"

    get profile_path("tusr2")
    !assert_tag content: /t2@t2.com/
  end

  should "display contact us for enterprises" do
    ent = Enterprise.create!(name: "my test enterprise", identifier: "my-test-enterprise")
    ent.boxes.first.blocks << block = ProfileInfoBlock.create!
    get profile_path("my-test-enterprise")
    assert_match /\/contact\/my-test-enterprise\/new/, @response.body
  end

  should "not display contact us for non-enterprises" do
    @profile.boxes.first.blocks << block = ProfileInfoBlock.create!
    get profile_path(@profile.identifier)
    assert_no_match /\/contact\/#{@profile.identifier}\/new/, @response.body
  end

  should "display contact us only if enabled" do
    ent = Enterprise.create! name: "my test enterprise", identifier: "my-test-enterprise"
    ent.boxes.first.blocks << block = ProfileInfoBlock.create!
    ent.update_attribute(:enable_contact_us, false)
    get profile_path(profile.identifier)
    assert_no_match /\/contact\/my-test-enterprise\/new/, @response.body
  end

  should "display contact button only if friends" do
    friend = create_user_full("friend_user").person
    friend.user.activate!
    friend.boxes.first.blocks << block = ProfileInfoBlock.create!
    @profile.add_friend(friend)
    env = Environment.default
    env.disable("disable_contact_person")
    env.save!
    login_as_rails5(@profile.identifier)
    get profile_path(friend.identifier)
    assert_match /\/contact\/#{friend.identifier}\/new/, @response.body
  end

  should "not display contact button if no friends" do
    nofriend = create_user_full("no_friend").person
    nofriend.boxes.first.blocks << block = ProfileInfoBlock.create!
    login_as_rails5(@profile.identifier)
    get profile_path(nofriend.identifier)
    assert_no_match /\/contact\/#{nofriend.identifier}\/new/, @response.body
  end

  should "display contact button only if friends and its enable in environment" do
    friend = create_user_full("friend_user").person
    friend.user.activate!
    friend.boxes.first.blocks << block = ProfileInfoBlock.create!
    env = Environment.default
    env.disable("disable_contact_person")
    env.save!
    @profile.add_friend(friend)
    login_as_rails5(@profile.identifier)
    get profile_path(friend.identifier)
    assert_match /\/contact\/#{friend.identifier}\/new/, @response.body
  end

  should "not display contact button if friends and its disable in environment" do
    friend = create_user_full("friend_user").person
    friend.boxes.first.blocks << block = ProfileInfoBlock.create!
    env = Environment.default
    env.enable("disable_contact_person")
    env.save!
    @profile.add_friend(friend)
    login_as_rails5(@profile.identifier)
    get profile_path(friend.identifier)
    assert_no_match /\/contact\/#{friend.identifier}\/new/, @response.body
  end

  should "display contact button for community if its enable in environment" do
    env = Environment.default
    community = create(Community, name: "my test community", environment: env)
    community.boxes.first.blocks << block = ProfileInfoBlock.create!
    env.disable("disable_contact_community")
    env.save!
    community.add_member(@profile)
    login_as_rails5(@profile.identifier)
    get profile_path(community.identifier)
    assert_match /\/contact\/#{community.identifier}\/new/, @response.body
  end

  should "not display contact button for community if its disable in environment" do
    env = Environment.default
    community = create(Community, name: "my test community", environment: env)
    community.boxes.first.blocks << block = ProfileInfoBlock.create!
    env.enable("disable_contact_community")
    env.save!
    community.add_member(@profile)
    login_as_rails5(@profile.identifier)
    get profile_path(community.identifier)
    assert_no_match /\/contact\/#{community.identifier}\/new/, @response.body
  end

  should "actually join profile" do
    community = Community.create!(name: "my test community")
    login_as_rails5 @profile.identifier
    post join_profile_path(community.identifier)

    assert_response :success
    assert_template nil

    profile = Profile.find(@profile.id)
    assert profile.memberships.include?(community), "profile should be actually added to the community"
  end

  should "create a task when joining a closed organization with members" do
    community = fast_create(Community)
    community.update_attribute(:closed, true)
    admin = create_user.person
    community.add_member(admin)

    login_as_rails5 profile.identifier
    assert_difference "AddMember.count" do
      post join_profile_path(community.identifier)
    end
  end

  should "not create task when join to closed and empty organization" do
    community = fast_create(Community)
    community.update_attribute(:closed, true)

    login_as_rails5 profile.identifier
    assert_no_difference "AddMember.count" do
      post join_profile_path(community.identifier)
    end
  end

  should "require login to join community" do
    community = Community.create!(name: "my test community", closed: true)
    get join_profile_path(community.identifier)

    assert_redirected_to controller: "account", action: "login"
  end

  should "show regular join button for person with public email" do
    community = Community.create!(name: "my test community", closed: true, requires_email: true)
    Person.any_instance.stubs(:public_fields).returns(["email"])
    login_as_rails5(@profile.identifier)

    get profile_path(community.identifier)
    !assert_tag tag: "a", attributes: { class: /modal-toggle join-community/ }
  end

  should "show join modal for person with private email" do
    community = Community.create!(name: "my test community", closed: true, requires_email: true)
    Person.any_instance.stubs(:public_fields).returns([])
    login_as_rails5(@profile.identifier)

    get profile_path(community.identifier)
    assert_tag tag: "a", attributes: { class: /open-modal join-community/ }
  end

  should "show regular join button for community without email visibility requirement" do
    community = Community.create!(name: "my test community", closed: true, requires_email: false)
    Person.any_instance.stubs(:public_fields).returns([])
    login_as_rails5(@profile.identifier)

    get profile_path(community.identifier)
    !assert_tag tag: "a", attributes: { class: /modal-toggle join-community/ }
  end

  should "show regular join button for community without email visibility requirement and person with public email" do
    community = Community.create!(name: "my test community", closed: true, requires_email: false)
    Person.any_instance.stubs(:public_fields).returns(["email"])
    login_as_rails5(@profile.identifier)

    get profile_path(community.identifier)
    !assert_tag tag: "a", attributes: { class: /modal-toggle join-community/ }
  end

  should "render join modal for community with email visibility requirement and person with private email" do
    community = Community.create!(name: "my test community", closed: true, requires_email: true)
    login_as_rails5 @profile.identifier
    post join_profile_path(community.identifier)
    assert_template "join"
  end

  should "create add member task from join-community modal" do
    community = Community.create!(name: "my test community", closed: true, requires_email: true)
    admin = create_user("community-admin").person
    community.add_admin(admin)

    login_as_rails5 @profile.identifier
    assert_difference "AddMember.count" do
      post join_modal_profile_path(community.identifier)
    end
    assert_redirected_to action: "index"
  end

  should "actually leave profile" do
    community = fast_create(Community)
    admin = fast_create(Person)
    community.add_member(admin)

    community.add_member(profile)
    assert_includes profile.memberships, community

    login_as_rails5(profile.identifier)
    post leave_profile_path(community.identifier)

    profile = Profile.find(@profile.id)
    assert_not_includes profile.memberships, community
  end

  should "require login to leave community" do
    community = Community.create!(name: "my test community")
    get leave_profile_path(community.identifier)

    assert_redirected_to controller: "account", action: "login"
  end

  should "not leave if is last admin" do
    community = fast_create(Community)

    community.add_admin(profile)
    assert_includes profile.memberships, community

    login_as_rails5(profile.identifier)
    post leave_profile_path(community.identifier)

    profile.reload
    assert_response :success
    assert_match(/last_admin/, @response.body)
    assert_includes profile.memberships, community
  end

  should "store location before login when request join via get not logged" do
    community = Community.create!(name: "my test community")

    get join_profile_path(community.identifier), headers: { "HTTP_REFERER" => "/profile/#{community.identifier}" }

    assert_equal "/profile/#{community.identifier}", @request.session[:previous_location]
  end

  should "redirect to login after user not logged asks to join a community" do
    community = Community.create!(name: "my test community")

    get join_not_logged_profile_path(community.identifier)

    assert_equal community.identifier, @request.session[:join]
    assert_redirected_to controller: :account, action: :login, return_to: community.url
  end

  should "redirect to join after user logged asks to join_not_logged a community" do
    community = Community.create!(name: "my test community")

    login_as_rails5(profile.identifier)
    get join_not_logged_profile_path(community.identifier)

    assert_equal community.identifier, @request.session[:join]
    assert_redirected_to controller: :profile, action: :join
  end

  should "show number of published events in index" do
    profile.articles << Event.new(name: "Published event", start_date: Date.today)
    profile.articles << Event.new(name: "Unpublished event", start_date: Date.today, published: false)

    get profile_path(profile.identifier)
    assert_tag tag: "a", content: "1", attributes: { href: "/profile/testuser/events" }
  end

  should "show number of published posts in index" do
    profile.articles << blog = create(Blog, name: "Blog", profile_id: profile.id)
    fast_create(TextArticle, name: "Published post", parent_id: profile.blog.id, profile_id: profile.id)
    fast_create(TextArticle, name: "Other published post", parent_id: profile.blog.id, profile_id: profile.id)
    fast_create(TextArticle, name: "Unpublished post", parent_id: profile.blog.id, profile_id: profile.id, published: false)

    get profile_path(profile.identifier)
    assert_tag tag: "a", content: "2 posts", attributes: { href: /\/testuser\/#{blog.slug}/ }
  end

  should "show number of published images in index" do
    folder = Gallery.create!(name: "gallery", profile: profile)
    published_file = UploadedFile.create!(profile: profile, parent: folder, uploaded_data: fixture_file_upload("/files/rails.png", "image/png"))
    unpublished_file = UploadedFile.create!(profile: profile, parent: folder, uploaded_data: fixture_file_upload("/files/other-pic.jpg", "image/jpg"), published: false)

    get profile_path(profile.identifier)
    assert_tag tag: "a", content: "One picture", attributes: { href: /\/testuser\/gallery/ }
  end

  should "show tags in index" do
    article = create(Article, name: "Published at", profile_id: profile.id, tag_list: ["tag1"])
    get profile_path(profile.identifier)
    assert_tag tag: "a", content: "tag1", attributes: { href: /profile\/#{profile.identifier}\/tags\/tag1$/ }
  end

  should "show description of orgarnization" do
    login_as_rails5(@profile.identifier)
    ent = fast_create(Enterprise)
    ent.description = "<span>Enterprise's description</span>"
    ent.save
    get profile_path(ent.identifier)
    assert_tag tag: "div", attributes: { class: "public-profile-description" }, content: /Enterprise\'s description/
  end

  should "show description of person" do
    environment = Environment.default
    environment.custom_person_fields = { description: { active: true, required: false, signup: false } }
    environment.save!
    environment.reload
    login_as_rails5(@profile.identifier)
    @profile.description = "Person description"
    @profile.save!
    get profile_path(@profile.identifier)
    assert_tag tag: "div", attributes: { class: "public-profile-description" }, content: /Person description/
  end

  should "not show description of orgarnization if not filled" do
    login_as_rails5(@profile.identifier)
    ent = fast_create(Enterprise)
    get profile_path(ent.identifier)
    !assert_tag tag: "div", attributes: { class: "public-profile-description" }
  end

  should "not show description of person if not filled" do
    login_as_rails5(@profile.identifier)
    get profile_path(@profile.identifier)
    !assert_tag tag: "div", attributes: { class: "public-profile-description" }
  end

  should "ask for login if user not logged" do
    enterprise = fast_create(Enterprise)
    get unblock_profile_path(enterprise.identifier)
    assert_redirected_to controller: "account", action: "login"
  end

  should " not allow ordinary users to unblock enterprises" do
    login_as_rails5(profile.identifier)
    enterprise = fast_create(Enterprise)
    get unblock_profile_path(enterprise.identifier)
    assert_response 403
  end

  should "allow environment admin to unblock enterprises" do
    login_as_rails5(profile.identifier)
    enterprise = fast_create(Enterprise)
    enterprise.environment.add_admin(profile)
    get unblock_profile_path(enterprise.identifier)
    assert_response 302
  end

  should "escape xss attack in tag feed" do
    get content_tagged_profile_path(profile.identifier), params: { id: "<wslite>" }
    !assert_tag tag: "wslite"
  end

  should "reverse the order of posts in tag feed" do
    create(TextArticle, name: "First post", profile: profile, tag_list: "tag1", published_at: Time.now)
    create(TextArticle, name: "Second post", profile: profile, tag_list: "tag1", published_at: Time.now + 1.day)

    get tag_feed_profile_path(profile.identifier), params: { id: "tag1" }
    assert_match(/Second.*First/, @response.body)
  end

  should "display the most recent posts in tag feed" do
    start = Time.now - 30.days
    first = create(TextArticle, name: "First post", profile: profile, tag_list: "tag1", published_at: start)
    20.times do |i|
      create(TextArticle, name: "Post #" + i.to_s, profile: profile, tag_list: "tag1", published_at: start + i.days)
    end
    last = create(TextArticle, name: "Last post", profile: profile, tag_list: "tag1", published_at: Time.now)

    get tag_feed_profile_path(profile.identifier), params: { id: "tag1" }
    assert_no_match(/First post/, @response.body) # First post is older than other 20 posts already
    assert_match(/Last post/, @response.body) # Latest post must come in the feed
  end

  should "be logged in to leave a scrap" do
    count = Scrap.count
    post leave_scrap_profile_path(profile.identifier), params: { scrap: { content: "something" } }
    assert_equal count, Scrap.count
    assert_redirected_to controller: "account", action: "login"
  end

  should "leave a scrap in the own profile" do
    login_as_rails5(profile.identifier)
    count = Scrap.count
    assert profile.scraps_received.empty?
    post leave_scrap_profile_path(profile.identifier), params: { scrap: { content: "something" } }
    assert_equal count + 1, Scrap.count
    assert_response :success
    assert_equal "Message successfully sent.", assigns(:message)
    profile.reload
    refute profile.scraps_received.empty?
  end

  should "leave a scrap on another profile" do
    login_as_rails5(profile.identifier)
    count = Scrap.count
    another_person = create_user.person
    assert another_person.scraps_received.empty?
    post leave_scrap_profile_path(another_person.identifier), params: { scrap: { content: "something" } }
    assert_equal count + 1, Scrap.count
    assert_response :success
    assert_equal "Message successfully sent.", assigns(:message)
    another_person.reload
    refute another_person.scraps_received.empty?
  end

  should "the owner of scrap could remove it" do
    login_as_rails5(profile.identifier)
    scrap = fast_create(Scrap, sender_id: profile.id)
    count = Scrap
    assert_difference "Scrap.count", -1 do
      post remove_scrap_profile_path(profile.identifier), params: { scrap_id: scrap.id }
    end
  end

  should "the receiver scrap remove it" do
    login_as_rails5(profile.identifier)
    scrap = fast_create(Scrap, receiver_id: profile.id)
    count = Scrap
    assert_difference "Scrap.count", -1 do
      post remove_scrap_profile_path(profile.identifier), params: { scrap_id: scrap.id }
    end
  end

  should "not remove others scraps" do
    login_as_rails5(profile.identifier)
    person = fast_create(Person)
    scrap = fast_create(Scrap, sender_id: person.id, receiver_id: person.id)
    count = Scrap
    assert_difference "Scrap.count", 0 do
      post remove_scrap_profile_path(profile.identifier), params: { scrap_id: scrap.id }
    end
  end

  should "be logged in to remove a scrap" do
    count = Scrap.count
    post remove_scrap_profile_path(profile.identifier), params: { scrap: { content: "something" } }
    assert_equal count, Scrap.count
    assert_redirected_to controller: "account", action: "login"
  end

  should "not remove an scrap of another user" do
    login_as_rails5(profile.identifier)
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    scrap = fast_create(Scrap, sender_id: p1.id, receiver_id: p2.id)
    count = Scrap.count
    post remove_scrap_profile_path(p2.identifier), params: { scrap_id: scrap.id }
    assert_equal count, Scrap.count
  end

  should "the sender be the logged user by default" do
    login_as_rails5(profile.identifier)
    count = Scrap.count
    another_person = create_user.person
    post leave_scrap_profile_path(another_person.identifier), params: { scrap: { content: "something" } }
    last = Scrap.last
    assert_equal profile, last.sender
  end

  should "the receiver be the current profile by default" do
    login_as_rails5(profile.identifier)
    count = Scrap.count
    another_person = create_user.person
    post leave_scrap_profile_path(another_person.identifier), params: { scrap: { content: "something" } }
    last = Scrap.last
    assert_equal another_person, last.receiver
  end

  should "report to user the scrap errors on creation" do
    login_as_rails5(profile.identifier)
    count = Scrap.count
    post leave_scrap_profile_path(profile.identifier), params: { scrap: { content: "" } }
    assert_response :success
    assert_equal "You can't leave an empty message.", assigns(:message)
  end

  should "display a scrap sent" do
    another_person = fast_create(Person)
    create(Scrap, defaults_for_scrap(sender: another_person, receiver: profile, content: "A scrap"))
    login_as_rails5(profile.identifier)
    get profile_path(profile.identifier)
    assert_tag tag: "p", content: "A scrap"
  end

  should "not display a scrap sent by a removed user" do
    another_person = fast_create(Person)
    create(Scrap, defaults_for_scrap(sender: another_person, receiver: profile, content: "A scrap"))
    login_as_rails5(profile.identifier)
    another_person.destroy
    get profile_path(profile.identifier)
    !assert_tag tag: "p", content: "A scrap"
  end

  should "see the activities_items paginated" do
    p1 = create_user("some").person
    ActionTracker::Record.destroy_all
    40.times { create(Scrap, defaults_for_scrap(sender: p1, receiver: p1)) }
    login_as_rails5(p1.identifier)
    get profile_path(p1.identifier)
    assert_equal 15, assigns(:activities).size
  end

  should "not see the followers activities in the current profile" do
    circle = Circle.create!(person: profile, name: "Zombies", profile_type: "Person")

    p2 = create_user.person
    refute profile.follows?(p2)
    p3 = create_user.person
    profile.follow(p3, circle)
    assert profile.follows?(p3)

    ActionTracker::Record.destroy_all

    scrap1 = create(Scrap, defaults_for_scrap(sender: p2, receiver: p3))
    scrap2 = create(Scrap, defaults_for_scrap(sender: p2, receiver: profile))

    User.current = p3.user
    article1 = TextArticle.create!(profile: p3, name: "An article about free software")

    User.current = p2.user
    article2 = TextArticle.create!(profile: p2, name: "Another article about free software")

    login_as_rails5(profile.identifier)
    get profile_path(p3.identifier)
    assert_not_nil assigns(:activities)
    assert_equivalent [scrap1, article1.activity], assigns(:activities).map(&:activity)
  end

  should "see all the activities in the current profile network" do
    p1 = create_user.person
    p2 = create_user.person
    refute p1.is_a_friend?(p2)

    p3 = create_user.person
    p3.add_friend(p1)
    p1.add_friend(p3)

    ActionTracker::Record.destroy_all

    User.current = p1.user
    create(Scrap, sender: p1, receiver: p1)
    a1 = ActionTracker::Record.last

    User.current = p2.user
    create(Scrap, sender: p2, receiver: p3)

    User.current = p3.user
    create(Scrap, sender: p3, receiver: p1)
    a3 = ActionTracker::Record.last

    process_delayed_job_queue

    login_as_rails5 p1.user.login
    get profile_path(p1.identifier)
    assert_equivalent [a1, a3].map(&:id), assigns(:network_activities).map(&:id)
  end

  should "the network activity be paginated" do
    User.current = user = create_user
    p1 = create_user("some").person
    40.times { fast_create(ActionTrackerNotification, action_tracker_id: create(ActionTracker::Record, verb: :leave_scrap, user: p1, params: { content: "blah" }), profile_id: p1.id) }

    login_as_rails5(p1.identifier)
    get profile_path(p1.identifier)
    assert_equal 15, assigns(:network_activities).size
  end

  should "the activities be the received scraps in people profile" do
    p1 = create_user("some").person
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    s1 = create(Scrap, sender_id: p1.id, receiver_id: p2.id, updated_at: Time.now)
    s2 = create(Scrap, sender_id: p2.id, receiver_id: p1.id, updated_at: Time.now + 1)
    s3 = create(Scrap, sender_id: p3.id, receiver_id: p1.id, updated_at: Time.now + 2)

    login_as_rails5(p1.identifier)
    get profile_path(p1.identifier)
    assert_equal [s3, s2], assigns(:activities).map(&:activity).select { |a| a.kind_of?(Scrap) }
  end

  should "the activities be the received scraps in community profile" do
    c = fast_create(Community)
    p1 = fast_create(Person)
    p2 = create_user("some").person
    p3 = fast_create(Person)
    s1 = create(Scrap, sender_id: p1.id, receiver_id: p2.id)
    s2 = create(Scrap, sender_id: p2.id, receiver_id: c.id)
    s3 = create(Scrap, sender_id: p3.id, receiver_id: c.id)

    login_as_rails5(p2.identifier)
    Person.any_instance.stubs(:follows?).returns(true)
    get profile_path(c.identifier)
    assert_equivalent [s2, s3], assigns(:activities).map(&:activity)
  end

  should "the activities be paginated in people profiles" do
    p1 = create_user("some").person
    40.times { create(Scrap, sender: p1, receiver: p1, created_at: Time.now) }

    assert_equal 40, p1.scraps_received.not_replies.count
    login_as_rails5(p1.identifier)
    get profile_path(p1.identifier)
    assert_equal 15, assigns(:activities).size
  end

  should "the activities be paginated in community profiles" do
    p1 = create_user("some").person
    c = fast_create(Community)
    40.times { create(Scrap, sender: p1, receiver: c) }

    login_as_rails5(p1.identifier)
    assert_equal 40, c.scraps_received.not_replies.count
    get profile_path(c.identifier)
    assert_equal 15, assigns(:activities).size
  end

  should "the owner of activity could remove it" do
    login_as_rails5(profile.identifier)
    at = fast_create(ActionTracker::Record, user_id: profile.id)
    assert_difference "ActionTracker::Record.count", -1 do
      post remove_activity_profile_path(profile.identifier), params: { activity_id: at.id }
    end
  end

  should "remove the network activities dependent an ActionTracker::Record" do
    login_as_rails5(profile.identifier)
    person = fast_create(Person)
    at = fast_create(ActionTracker::Record, user_id: profile.id)
    atn = fast_create(ActionTrackerNotification, profile_id: person.id, action_tracker_id: at.id)
    count = ActionTrackerNotification
    assert_difference "ActionTrackerNotification.count", -1 do
      post remove_activity_profile_path(profile.identifier), params: { activity_id: at.id }
    end
  end

  should "be logged in to remove the activity" do
    at = fast_create(ActionTracker::Record, user_id: profile.id)
    atn = fast_create(ActionTrackerNotification, profile_id: profile.id, action_tracker_id: at.id)
    count = ActionTrackerNotification.count
    post remove_activity_profile_path(profile.identifier), params: { activity_id: at.id }
    assert_equal count, ActionTrackerNotification.count
    assert_redirected_to controller: "account", action: "login"
  end

  should "remove an activity of another person if user has permissions to edit it" do
    user = create_user("another_user").person
    owner = create_user("owner").person
    login_as_rails5(user.identifier)
    activity = fast_create(ActionTracker::Record, user_id: owner.id)

    assert_no_difference "ActionTracker::Record.count" do
      post remove_activity_profile_path(owner.identifier), params: { activity_id: activity.id }
    end

    owner.environment.add_admin(user)

    assert_difference "ActionTracker::Record.count", -1 do
      post remove_activity_profile_path(owner.identifier), params: { activity_id: activity.id }
    end
  end

  should "remove a notification of another profile if user has permissions to edit it" do
    user = create_user("owner").person
    login_as_rails5(user.identifier)
    profile = fast_create(Profile)
    activity = fast_create(ActionTracker::Record, user_id: user.id)
    fast_create(ActionTrackerNotification, profile_id: profile.id, action_tracker_id: activity.id)
    #    #@controller.stubs(:user).returns(user)
    #    #@controller.stubs(:profile).returns(profile)

    assert_no_difference "ActionTrackerNotification.count" do
      post remove_notification_profile_path(profile.identifier), params: { activity_id: activity.id }
    end

    profile.environment.add_admin(user)

    assert_difference "ActionTrackerNotification.count", -1 do
      post remove_activity_profile_path(profile.identifier), params: { activity_id: activity.id }
    end
  end

  should "not show the network activity if the viewer don't follow the profile" do
    login_as_rails5(profile.identifier)
    person = fast_create(Person)
    at = fast_create(ActionTracker::Record, user_id: person.id)
    atn = fast_create(ActionTrackerNotification, profile_id: profile.id, action_tracker_id: at.id)
    get profile_path(person.identifier)
    !assert_tag tag: "div", attributes: { id: "profile-network" }
  end

  should "not show the scrap button on network activity if the user is himself" do
    login_as_rails5(profile.identifier)
    at = fast_create(ActionTracker::Record, user_id: profile.id)
    atn = fast_create(ActionTrackerNotification, profile_id: profile.id, action_tracker_id: at.id)
    get profile_path(profile.identifier)
    !assert_tag tag: "p", attributes: { class: "profile-network-send-message" }
  end

  should "not show the scrap area on wall for visitor" do
    get profile_path(profile.identifier)
    !assert_tag tag: "div", attributes: { id: "leave_scrap" }, descendant: { tag: "input", attributes: { value: "Share" } }
  end

  should "not show the scrap area on wall for stranger" do
    person = create_user("stranger").person
    login_as_rails5(person.identifier)
    get profile_path(profile.identifier)
    !assert_tag tag: "div", attributes: { id: "leave_scrap" }, descendant: { tag: "input", attributes: { value: "Share" } }
  end

  should "show the scrap area on wall for the user" do
    login_as_rails5(profile.identifier)
    get profile_path(profile.identifier)
    assert_tag tag: "div", attributes: { id: "leave_scrap" }, descendant: { tag: "input", attributes: { value: "Publish" } }
  end

  should "show the scrap area on wall for a friend" do
    login_as_rails5(profile.identifier)
    person = fast_create(Person)
    person.add_friend(profile)
    profile.add_friend(person)

    get profile_path(person.identifier)
    assert_tag tag: "div", attributes: { id: "leave_scrap" }, descendant: { tag: "input", attributes: { value: "Publish" } }
  end

  should "show the scrap area on wall for a member" do
    login_as_rails5(profile.identifier)
    community = fast_create(Community)
    community.add_member(profile)

    get profile_path(community.identifier)
    assert_tag tag: "div", attributes: { id: "leave_scrap" }, descendant: { tag: "input", attributes: { value: "Publish" } }
  end

  should "not show the scrap button on wall activity if the user is himself" do
    login_as_rails5(profile.identifier)
    scrap = fast_create(Scrap, sender_id: profile.id, receiver_id: profile.id)
    get profile_path(profile.identifier)
    !assert_tag tag: "p", attributes: { class: "profile-wall-send-message" }
  end

  should "not show the activities to offline users if the profile is private" do
    at = fast_create(ActionTracker::Record, user_id: profile.id)
    profile.access = Entitlement::Levels.levels[:self]
    profile.save
    atn = fast_create(ActionTrackerNotification, profile_id: profile.id, action_tracker_id: at.id)
    get profile_path(profile.identifier)
    assert_equal [at], profile.tracked_actions
    !assert_tag tag: "li", attributes: { id: "profile-activity-item-#{atn.id}" }
  end

  should "view more activities paginated" do
    login_as_rails5(profile.identifier)
    article = TextArticle.create!(profile: profile, name: "An Article about Free Software")
    ActionTracker::Record.destroy_all
    40.times { create(ActionTracker::Record, user_id: profile.id, user_type: "Profile", verb: "create_article", target_id: article.id, target_type: "Article", params: { "name" => article.name, "url" => article.url, "lead" => article.lead, "first_image" => article.first_image }) }
    assert_equal 40, profile.tracked_actions.count
    assert_equal 40, profile.activities.size
    get view_more_activities_profile_path(profile.identifier), params: { page: 2, kind: "wall", offsets: { wall: 0, network: 0 } }
    assert_response :success
    assert_template "_profile_activities_list"
    assert_equal ProfileController::ACTIVITIES_PER_PAGE, assigns(:activities).size
  end

  should "be logged in to access the view_more_activities action" do
    get view_more_activities_profile_path(profile.identifier), params: { kind: "wall", offsets: { wall: 0, network: 0 } }
    assert_redirected_to controller: "account", action: "login"
  end

  should "view more network activities paginated" do
    login_as_rails5(profile.identifier)
    40.times { fast_create(ActionTrackerNotification, profile_id: profile.id, action_tracker_id: fast_create(ActionTracker::Record, user_id: profile.id)) }
    assert_equal 40, profile.tracked_notifications.count
    get view_more_activities_profile_path(profile.identifier), params: { page: 2, kind: "network", offsets: { wall: 0, network: 0 } }
    assert_response :success
    assert_template "_profile_network_activities"
    assert_equal ProfileController::ACTIVITIES_PER_PAGE, assigns(:activities).size
  end

  should "be logged in to access the view_more_network_activities action" do
    get view_more_activities_profile_path(profile.identifier), params: { kind: "network", offsets: { wall: 0, network: 0 } }
    assert_redirected_to controller: "account", action: "login"
  end

  should "not index display activities comments" do
    login_as_rails5(profile.identifier)
    article = TextArticle.create!(profile: profile, name: "An Article about Free Software")
    ActionTracker::Record.destroy_all
    activity = create(ActionTracker::Record, user_id: profile.id, user_type: "Profile", verb: "create_article", target_id: article.id, target_type: "Article", params: { "name" => article.name, "url" => article.url, "lead" => article.lead, "first_image" => article.first_image })
    20.times { comment = fast_create(Comment, source_id: article, title: "a comment", body: "lalala", created_at: Time.now) }
    article.reload
    get profile_path(profile.identifier)
    assert_tag "ul", attributes: { class: "profile-wall-activities-comments" }, children: { count: 0 }
  end

  should "view more comments paginated" do
    login_as_rails5(profile.identifier)
    article = TextArticle.create!(profile: profile, name: "An Article about Free Software")
    ActionTracker::Record.destroy_all
    activity = create(ActionTracker::Record, user_id: profile.id, user_type: "Profile", verb: "create_article", target_id: article.id, target_type: "Article", params: { "name" => article.name, "url" => article.url, "lead" => article.lead, "first_image" => article.first_image })
    20.times { comment = fast_create(Comment, source_id: article, title: "a comment", body: "lalala", created_at: Time.now) }
    article.reload
    assert_equal 20, article.comments.count
    get more_comments_profile_path(profile.identifier), params: { activity: activity.id, comment_page: 2 }, xhr: true
    assert_response :success
    assert_template "_comment"
    assert_select "li", 5 # 5 comments per page
  end

  should "not index display scraps replies" do
    login_as_rails5(profile.identifier)
    Scrap.destroy_all
    scrap = create(Scrap, sender_id: profile.id, receiver_id: profile.id)
    20.times { create(Scrap, sender_id: profile.id, receiver_id: profile.id, scrap_id: scrap.id) }
    profile.reload
    get profile_path(profile.identifier)
    assert_tag "ul", attributes: { class: "profile-wall-activities-comments scrap-replies" }, children: { count: 0 }
  end

  should "view more replies paginated" do
    login_as_rails5(profile.identifier)
    Scrap.destroy_all
    scrap = fast_create(Scrap, sender_id: profile.id, receiver_id: profile.id)
    20.times { fast_create(Scrap, sender_id: profile.id, receiver_id: profile.id, scrap_id: scrap.id) }
    profile.reload
    assert_equal 20, scrap.replies.count
    get more_replies_profile_path(profile.identifier), params: { activity: scrap.id, comment_page: 2 }, xhr: true
    assert_response :success
    assert_template "_profile_scrap"
    assert_select "li", 5 # 5 replies per page
  end

  should "render empty response for not logged in users in check_membership" do
    get check_membership_profile_path(profile.identifier)
    assert_equal "", @response.body
  end

  should "render empty response for not logged in users in check_friendship" do
    get check_friendship_profile_path(profile.identifier)
    assert_equal "", @response.body
  end

  should "display plugins tabs" do
    class Plugin1 < Noosfero::Plugin
      def profile_tabs
        { title: "Plugin1 tab", id: "plugin1_tab", content: proc { "Content from plugin1.".html_safe } }
      end
    end

    class Plugin2 < Noosfero::Plugin
      def profile_tabs
        { title: "Plugin2 tab", id: "plugin2_tab", content: proc { "Content from plugin2.".html_safe } }
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.to_s, Plugin2.to_s])

    e = profile.environment
    e.enable_plugin(Plugin1.name)
    e.enable_plugin(Plugin2.name)

    get profile_path(profile.identifier)

    plugin1 = Plugin1.new
    plugin2 = Plugin2.new

    assert_tag tag: "a", content: /#{plugin1.profile_tabs[:title]}/, attributes: { href: /#{plugin1.profile_tabs[:id]}/ }
    assert_tag tag: "div", content: /#{instance_eval(&plugin1.profile_tabs[:content])}/, attributes: { id: /#{plugin1.profile_tabs[:id]}/ }
    assert_tag tag: "a", content: /#{plugin2.profile_tabs[:title]}/, attributes: { href: /#{plugin2.profile_tabs[:id]}/ }
    assert_tag tag: "div", content: /#{instance_eval(&plugin2.profile_tabs[:content])}/, attributes: { id: /#{plugin2.profile_tabs[:id]}/ }
  end

  should "check different profile from the domain profile" do
    default = Environment.default
    default.domains.create!(name: "environment.com")
    profile = create_user("another_user").person
    domain_profile = create_user("domain_user").person
    domain_profile.domains.create!(name: "profiledomain.com")

    get profile_path(profile.identifier), headers: { "HOST" => "profiledomain.com" }
    assert_response :redirect
    assert_redirected_to @request.params.merge(host: profile.default_hostname)

    get profile_path(profile.identifier), headers: { "HOST" => profile.default_hostname }
    assert_response :success
  end

  should "redirect to profile domain if it has one" do
    community = fast_create(Community, name: "community with domain")
    community.domains << Domain.new(name: "community.example.net")
    get profile_path(community.identifier), headers: { "HOST" => community.environment.default_hostname }
    assert_response :redirect
    assert_redirected_to host: "community.example.net", controller: "profile", action: "index"
  end

  should "register abuse report" do
    reported = fast_create(Profile)
    login_as_rails5(profile.identifier)
    #    #@controller.stubs(:verify_recaptcha).returns(true)

    assert_difference "AbuseReport.count", 1 do
      post register_report_profile_path(reported.identifier), params: { abuse_report: { reason: "some reason" } }
    end
  end

  should "register abuse report with content" do
    reported = fast_create(Profile)
    content = fast_create(TextArticle, profile_id: reported.id)
    login_as_rails5(profile.identifier)
    #    #@controller.stubs(:verify_recaptcha).returns(true)

    assert_difference "AbuseReport.count", 1 do
      post register_report_profile_path(reported.identifier), params: { abuse_report: { reason: "some reason" }, content_type: content.class.name, content_id: content.id }
    end
  end

  should "not ask admin for captcha to register abuse" do
    reported = fast_create(Profile)
    login_as_rails5(profile.identifier)
    environment = Environment.default
    environment.add_admin(profile)
    # #@controller.expects(:verify_recaptcha).never

    assert_difference "AbuseReport.count", 1 do
      post register_report_profile_path(reported.identifier), params: { abuse_report: { reason: "some reason" } }
    end
  end

  should "display activities and scraps together" do
    another_person = fast_create(Person)
    create(Scrap, defaults_for_scrap(sender: another_person, receiver: profile, content: "A scrap"))

    User.current = profile.user
    ActionTracker::Record.destroy_all
    TextArticle.create!(profile: profile, name: "An article about free software")

    login_as_rails5(profile.identifier)
    get profile_path(profile.identifier)

    assert_tag tag: "p", content: "A scrap", attributes: { class: "profile-activity-text" }
    assert_tag tag: "div", attributes: { class: "profile-activity-lead" }, descendant: { tag: "a", content: "An article about free software" }
  end

  should "have scraps and activities on activities" do
    another_person = fast_create(Person)
    scrap = create(Scrap, defaults_for_scrap(sender: another_person, receiver: profile, content: "A scrap"))

    User.current = profile.user
    ActionTracker::Record.destroy_all
    TextArticle.create!(profile: profile, name: "An article about free software")
    activity = ActionTracker::Record.last

    login_as_rails5(profile.identifier)
    get profile_path(profile.identifier)

    assert_equivalent [scrap, activity], assigns(:activities).map(&:activity)
  end

  should "follow an article" do
    article = TextArticle.create!(profile: profile, name: "An article about free software")
    login_as_rails5(@profile.identifier)
    post follow_article_profile_path(profile.identifier), params: { article_id: article.id }
    assert_includes article.person_followers, @profile
  end

  should "unfollow an article" do
    article = TextArticle.create!(profile: profile, name: "An article about free software")
    article.person_followers << @profile
    article.save!
    assert_includes article.person_followers, @profile

    login_as_rails5(@profile.identifier)
    post unfollow_article_profile_path(profile.identifier), params: { article_id: article.id }
    assert_not_includes article.person_followers, @profile
  end

  should "be logged in to leave comment on an activity" do
    article = TextArticle.create!(profile: profile, name: "An article about free software")
    activity = ActionTracker::Record.last
    count = activity.comments.count

    post leave_comment_on_activity_profile_path(profile.identifier), params: { comment: { body: "something", source_id: activity.id } }
    assert_equal count, activity.comments.count
    assert_redirected_to controller: "account", action: "login"
  end

  should "leave a comment in own activity" do
    login_as_rails5(profile.identifier)
    TextArticle.create!(profile: profile, name: "An article about free software")
    activity = ActionTracker::Record.last
    count = activity.comments.count

    assert_equal 0, count
    post leave_comment_on_activity_profile_path(profile.identifier), params: { comment: { body: "something" }, source_id: activity.id }
    assert_equal count + 1, ActionTracker::Record.find(activity.id).comments_count
    assert_response :success
    assert_equal "Comment successfully added.", assigns(:message)
  end

  should "leave a comment on another profile's activity" do
    login_as_rails5(profile.identifier)
    another_person = fast_create(Person)
    TextArticle.create!(profile: another_person, name: "An article about free software")
    activity = ActionTracker::Record.last
    count = activity.comments.count
    assert_equal 0, count
    post leave_comment_on_activity_profile_path(another_person.identifier), params: { comment: { body: "something" }, source_id: activity.id }
    assert_equal count + 1, ActionTracker::Record.find(activity.id).comments_count
    assert_response :success
    assert_equal "Comment successfully added.", assigns(:message)
  end

  should "display comment in wall if user was removed after click in view all comments" do
    User.current = profile.user
    article = TextArticle.create!(profile: profile, name: "An article about free software")
    to_be_removed = create_user("removed_user").person
    comment = create(Comment, author: to_be_removed, title: "Test Comment", body: "My author does not exist =(", source_id: article.id, source_type: "Article")
    to_be_removed.destroy

    activity = ActionTracker::Record.last

    login_as_rails5(profile.identifier)
    get more_comments_profile_path(profile.identifier), params: { activity: activity.id, comment_page: 1, tab_action: "wall" }, xhr: true

    assert_select "span", content: "(removed user)", attributes: { class: "comment-user-status comment-user-status-wall icon-user-removed" }
  end

  should "not display spam comments in wall" do
    User.current = profile.user
    article = TextArticle.create!(profile: profile, name: "An article about spam's nutritional attributes")
    comment = create(Comment, author: profile, title: "Test Comment", body: "This article makes me hungry", source_id: article.id, source_type: "Article")
    comment.spam!
    login_as_rails5(profile.identifier)
    get profile_path(profile.identifier)

    refute /This article makes me hungry/.match(@response.body), "Spam comment was shown!"
  end

  should "display comment in wall from non logged users after click in view all comments" do
    User.current = profile.user
    article = TextArticle.create!(profile: profile, name: "An article about free software")
    comment = create(Comment, name: "outside user", email: "outside@localhost.localdomain", title: "Test Comment", body: "My author does not exist =(", source_id: article.id, source_type: "Article")

    login_as_rails5(profile.identifier)
    get profile_path(profile.identifier)

    activity = ActionTracker::Record.last

    logout_rails5
    login_as_rails5(profile.identifier)
    get more_comments_profile_path(profile.identifier), params: { activity: activity.id, comment_page: 1, tab_action: "wall" }, xhr: true

    assert_select "span", content: "(unauthenticated user)", attributes: { class: "comment-user-status comment-user-status-wall icon-user-unknown" }
  end

  should "add locale on mailing" do
    community = fast_create(Community)
    create_user_with_permission("profile_moderator_user", "send_mail_to_members", community)
    login_as_rails5("profile_moderator_user")
    ProfileController.any_instance.stubs(:locale).returns("pt")
    post send_mail_profile_path(community.identifier), params: { mailing: { subject: "Hello", body: "We have some news" } }
    assert_equal "pt", assigns(:mailing).locale
  end

  should "queue mailing to process later" do
    community = fast_create(Community)
    create_user_with_permission("profile_moderator_user", "send_mail_to_members", community)
    login_as_rails5("profile_moderator_user")
    # @controller.stubs(:locale).returns('pt')

    assert_difference "Delayed::Job.count", 1 do
      post send_mail_profile_path(community.identifier), params: { mailing: { subject: "Hello", body: "We have some news" } }
    end
  end

  # FIXME see a way to tests putting values on session
  #  should 'send to members_filtered if available' do
  #    community = fast_create(Community)
  #    create_user_with_permission('profile_moderator_user', 'send_mail_to_members', community)
  #    person = create_user('Any').person
  #    community.add_member(person)
  #    community.save!
  #    login_as_rails5('profile_moderator_user')
  #
  #    post send_mail_profile_path(community.identifier), params: { :mailing => {:subject => 'Hello', :body => 'We have some news'}}
  #    assert_equivalent community.members, OrganizationMailing.last.recipients
  #
  #    session['members_filtered'] = [person.id]
  #    post send_mail_profile_path(community.identifier), params: { :mailing => {:subject => 'RUN!!', :body => 'Run to the hills!!'}}#, session: { members_filtered: [person.id]}
  #    assert_equal [person], OrganizationMailing.last.recipients
  #  end
  #
  #  should 'send email to all members if there is no valid member in members_filtered' do
  #    community = fast_create(Community)
  #    create_user_with_permission('profile_moderator_user', 'send_mail_to_members', community)
  #    person = create_user('Any').person
  #    community.add_member(person)
  #    community.save!
  #    login_as_rails5('profile_moderator_user')
  #
  #    @request.session[:members_filtered] = [Profile.last.id+1]
  #    post send_mail_profile_path(community.identifier), params: { :mailing => {:subject => 'RUN!!', :body => 'Run to the hills!!'}}
  #    assert_empty OrganizationMailing.last.recipients
  #  end

  should "save mailing" do
    community = fast_create(Community)
    create_user_with_permission("profile_moderator_user", "send_mail_to_members", community)
    login_as_rails5("profile_moderator_user")
    # @controller.stubs(:locale).returns('pt')
    post send_mail_profile_path(community.identifier), params: { mailing: { subject: "Hello", body: "We have some news" } }
    assert_equal ["Hello", "We have some news"], [assigns(:mailing).subject, assigns(:mailing).body]
  end

  should "add the user logged on mailing" do
    community = fast_create(Community)
    create_user_with_permission("profile_moderator_user", "send_mail_to_members", community)
    login_as_rails5("profile_moderator_user")
    post send_mail_profile_path(community.identifier), params: { mailing: { subject: "Hello", body: "We have some news" } }
    assert_equal Profile["profile_moderator_user"], assigns(:mailing).person
  end

  should "redirect back to right place after mail" do
    community = fast_create(Community)
    create_user_with_permission("profile_moderator_user", "send_mail_to_members", community)
    login_as_rails5("profile_moderator_user")
    # @controller.stubs(:locale).returns('pt')
    post send_mail_profile_path(community.identifier), params: { mailing: { subject: "Hello", body: "We have some news" } }, headers: { "HTTP_REFERER" => "/profile/#{community.identifier}/members" }
    assert_redirected_to action: "members"
  end

  should "display email templates as an option to send mail" do
    community = fast_create(Community)
    create_user_with_permission("profile_moderator_user", "send_mail_to_members", community)
    login_as_rails5("profile_moderator_user")

    template1 = EmailTemplate.create!(owner: community, name: "Template 1", template_type: :organization_members)
    template2 = EmailTemplate.create!(owner: community, name: "Template 2")

    get send_mail_profile_path(community.identifier), params: { mailing: { subject: "Hello", body: "We have some news" } }
    assert_select ".template-selection"
    assert_equal [template1], assigns(:email_templates)
  end

  should "do not display email template selection when there is no template for organization members" do
    community = fast_create(Community)
    create_user_with_permission("profile_moderator_user", "send_mail_to_members", community)
    login_as_rails5("profile_moderator_user")

    get send_mail_profile_path(community.identifier), params: { mailing: { subject: "Hello", body: "We have some news" } }
    assert_select ".template-selection"
    assert assigns(:email_templates).empty?
  end

  should "show all fields to anonymous user" do
    viewed = create_user("person_1").person
    Environment.any_instance.stubs(:active_person_fields).returns(["sex", "birth_date"])
    Environment.any_instance.stubs(:required_person_fields).returns([])
    viewed.birth_date = Time.parse("2012-08-26").ago(22.years)
    viewed.data = { sex: "male", fields_privacy: { "sex" => "public", "birth_date" => "public" } }
    viewed.save!
    get profile_path(viewed.identifier)
    assert_tag tag: "td", content: "Sex"
    assert_tag tag: "td", content: "Male"
    assert_tag tag: "td", content: "Date of birth"
    assert_tag tag: "td", content: "August 26, 1990"
  end

  should "show some fields to anonymous user" do
    viewed = create_user("person_1").person
    Environment.any_instance.stubs(:active_person_fields).returns(["sex", "birth_date"])
    Environment.any_instance.stubs(:required_person_fields).returns([])
    viewed.birth_date = Time.parse("2012-08-26").ago(22.years)
    viewed.data = { sex: "male", fields_privacy: { "sex" => "public" } }
    viewed.save!
    get profile_path(viewed.identifier)
    assert_tag tag: "td", content: "Sex"
    assert_tag tag: "td", content: "Male"
    !assert_tag tag: "td", content: "Date of birth"
    !assert_tag tag: "td", content: "August 26, 1990"
  end

  should "show some fields to non friend" do
    viewed = create_user("person_1").person
    Environment.any_instance.stubs(:active_person_fields).returns(["sex", "birth_date"])
    Environment.any_instance.stubs(:required_person_fields).returns([])
    viewed.birth_date = Time.parse("2012-08-26").ago(22.years)
    viewed.data = { sex: "male", fields_privacy: { "sex" => "public" } }
    viewed.save!
    strange = create_user("person_2").person
    login_as_rails5(strange.identifier)
    get profile_path(viewed.identifier)
    assert_tag tag: "td", content: "Sex"
    assert_tag tag: "td", content: "Male"
    !assert_tag tag: "td", content: "Date of birth"
    !assert_tag tag: "td", content: "August 26, 1990"
  end

  should "show all fields to friend" do
    viewed = create_user("person_1").person
    friend = create_user("person_2").person
    Environment.any_instance.stubs(:active_person_fields).returns(["sex", "birth_date"])
    Environment.any_instance.stubs(:required_person_fields).returns([])
    viewed.birth_date = Time.parse("2012-08-26").ago(22.years)
    viewed.data = { sex: "male", fields_privacy: { "sex" => "public" } }
    viewed.save!
    Person.any_instance.stubs(:is_a_friend?).returns(true)
    login_as_rails5(friend.identifier)
    get profile_path(viewed.identifier)
    assert_tag tag: "td", content: "Sex"
    assert_tag tag: "td", content: "Male"
    assert_tag tag: "td", content: "Date of birth"
    assert_tag tag: "td", content: "August 26, 1990"
  end

  should "show all fields to self" do
    viewed = create_user("person_1").person
    Environment.any_instance.stubs(:active_person_fields).returns(["sex", "birth_date"])
    Environment.any_instance.stubs(:required_person_fields).returns([])
    viewed.birth_date = Time.parse("2012-08-26").ago(22.years)
    viewed.data = { sex: "male", fields_privacy: { "sex" => "public" } }
    viewed.save!
    login_as_rails5(viewed.identifier)
    get profile_path(viewed.identifier)
    assert_tag tag: "td", content: "Sex"
    assert_tag tag: "td", content: "Male"
    assert_tag tag: "td", content: "Date of birth"
    assert_tag tag: "td", content: "August 26, 1990"
  end

  should "show contact to non friend" do
    viewed = create_user("person_1").person
    Environment.any_instance.stubs(:required_person_fields).returns([])
    viewed.data = { email: "test@test.com", fields_privacy: { "email" => "public" } }
    viewed.save!
    strange = create_user("person_2").person
    login_as_rails5(strange.identifier)
    get profile_path(viewed.identifier)
    assert_tag tag: "th", content: "Contact"
    assert_tag tag: "td", content: "e-Mail"
  end

  should "show contact to friend" do
    viewed = create_user("person_1").person
    friend = create_user("person_2").person
    Environment.any_instance.stubs(:required_person_fields).returns([])
    viewed.data = { email: "test@test.com", fields_privacy: { "email" => "public" } }
    viewed.save!
    Person.any_instance.stubs(:is_a_friend?).returns(true)
    login_as_rails5(friend.identifier)
    get profile_path(viewed.identifier)
    assert_tag tag: "th", content: "Contact"
    assert_tag tag: "td", content: "e-Mail"
  end

  should "show contact to self" do
    viewed = create_user("person_1").person
    Environment.any_instance.stubs(:required_person_fields).returns([])
    viewed.data = { email: "test@test.com", fields_privacy: { "email" => "public" } }
    viewed.save!
    login_as_rails5(viewed.identifier)
    get profile_path(viewed.identifier)
    assert_tag tag: "th", content: "Contact"
    assert_tag tag: "td", content: "e-Mail"
  end

  should "not show contact to non friend" do
    viewed = create_user("person_1").person
    Environment.any_instance.stubs(:required_person_fields).returns([])
    viewed.data = { email: "test@test.com", fields_privacy: {} }
    viewed.save!
    strange = create_user("person_2").person
    login_as_rails5(strange.identifier)
    get profile_path(viewed.identifier)
    !assert_tag tag: "th", content: "Contact"
    !assert_tag tag: "td", content: "e-Mail"
  end

  should "show contact to friend even if private" do
    viewed = create_user("person_1").person
    friend = create_user("person_2").person
    Environment.any_instance.stubs(:required_person_fields).returns([])
    viewed.data = { email: "test@test.com", fields_privacy: {} }
    viewed.save!
    Person.any_instance.stubs(:is_a_friend?).returns(true)
    login_as_rails5(friend.identifier)
    get profile_path(viewed.identifier)
    assert_tag tag: "th", content: "Contact"
    assert_tag tag: "td", content: "e-Mail"
  end

  should "show contact to self even if private" do
    viewed = create_user("person_1").person
    Environment.any_instance.stubs(:required_person_fields).returns([])
    viewed.data = { email: "test@test.com", fields_privacy: {} }
    viewed.save!
    login_as_rails5(viewed.identifier)
    get profile_path(viewed.identifier)
    assert_tag tag: "th", content: "Contact"
    assert_tag tag: "td", content: "e-Mail"
  end

  should "not display list of communities to manage on menu by default" do
    user = create_user("community_admin").person
    community = fast_create(Community)
    community.add_admin(user)

    login_as_rails5(user.identifier)
    get profile_path(profile.identifier)
    !assert_tag tag: "ul", attributes: { id: "manage-communities" }
  end

  should "display list of communities to manage on menu if enabled" do
    user = create_user("community_admin").person
    env = user.environment
    community = fast_create(Community)
    community.add_admin(user)

    Environment.any_instance.stubs(:enabled?).returns(false)
    Environment.any_instance.stubs(:enabled?).with(:display_my_communities_on_user_menu).returns(true)

    login_as_rails5(user.identifier)
    get profile_path(profile.identifier)
    assert_tag tag: "ul", attributes: { id: "manage-communities" }
  end

  should "build menu to the community panel of communities the user can manage if enabled" do
    u = create_user("other_other_ze").person
    u2 = create_user("guy_that_will_be_admin_of_all").person # because the first member of each community is an admin

    Environment.any_instance.stubs(:enabled?).returns(false)
    Environment.any_instance.stubs(:enabled?).with(:display_my_communities_on_user_menu).returns(true)

    Environment.any_instance.stubs(:required_person_fields).returns([])
    u.data = { email: "test@test.com", fields_privacy: {} }
    u.save!
    c1 = fast_create(Community, name: "community_1")
    c2 = fast_create(Community, name: "community_2")
    c3 = fast_create(Community, name: "community_3")
    c4 = fast_create(Community, name: "community_4")

    c1.add_admin(u2)
    c2.add_admin(u2)
    c3.add_admin(u2)

    c1.add_member(u)
    c2.add_member(u)
    c3.add_member(u)
    c1.add_admin(u)
    c2.add_admin(u)

    login_as_rails5(u.identifier)

    get profile_path(profile.identifier)

    assert_tag tag: "ul", attributes: { id: "manage-communities" }
    doc = Nokogiri::HTML @response.body
    assert_select doc, "#manage-communities li > a" do |links|
      assert_equal 4, links.length
      assert_match /community_1/, links.to_s
      assert_match /community_2/, links.to_s
      assert_no_match /community_3/, links.to_s
      assert_no_match /community_4/, links.to_s
    end
  end

  should "build menu to the enterprise panel if enabled" do
    u = create_user("other_other_ze").person

    Environment.any_instance.stubs(:enabled?).returns(false)
    Environment.any_instance.stubs(:enabled?).with(:display_my_enterprises_on_user_menu).returns(true)

    Environment.any_instance.stubs(:required_person_fields).returns([])
    u.data = { email: "test@test.com", fields_privacy: {} }
    u.save!
    e1 = fast_create(Enterprise, identifier: "test_enterprise1", name: "Test enterprise1")
    e2 = fast_create(Enterprise, identifier: "test_enterprise2", name: "Test enterprise2")

    e1.add_member(u)

    login_as_rails5(u.identifier)

    get profile_path(profile.identifier)

    assert_tag tag: "ul", attributes: { id: "manage-enterprises" }
    doc = Nokogiri::HTML @response.body
    assert_select doc, "#manage-enterprises li > a" do |links|
      assert_equal 2, links.length # User menu and hamburger menu
      assert_match /Test enterprise1/, links.to_s
      assert_no_match /Test enterprise_2/, links.to_s
    end
  end

  should "not build menu to the enterprise panel if not enabled" do
    user = create_user("enterprise_admin").person
    enterprise = fast_create(Enterprise)
    enterprise.add_admin(user)

    Environment.any_instance.stubs(:enabled?).returns(false)
    Environment.any_instance.stubs(:enabled?).with(:display_my_enterprises_on_user_menu).returns(false)

    login_as_rails5(user.identifier)
    get profile_path(profile.identifier)
    !assert_tag tag: "div", attributes: { id: "manage-enterprises" }
  end

  should "show enterprises field if enterprises are enabled on environment" do
    person = fast_create(Person)
    enterprise = fast_create(Enterprise)
    enterprise.add_admin person
    environment = person.environment
    environment.disable("disable_asset_enterprises")
    environment.save!

    get profile_path(person.identifier)
    assert_tag tag: "td", content: "Enterprises"
    assert_tag tag: "td", descendant: { tag: "a", content: /#{person.enterprises.count}/, attributes: { href: /profile\/#{person.identifier}\/enterprises$/ } }
  end

  should "not show enterprises field if enterprises are disabled on environment" do
    person = fast_create(Person)
    enterprise = fast_create(Enterprise)
    enterprise.add_admin person
    environment = person.environment
    environment.enable("disable_asset_enterprises")
    environment.save!

    get profile_path(person.identifier)
    !assert_tag tag: "td", content: "Enterprises"
    !assert_tag tag: "td", descendant: { tag: "a", content: /#{person.enterprises.count}/, attributes: { href: /profile\/#{person.identifier}\/enterprises$/ } }
  end

  should "admins from a community be present in admin users div and members div" do
    community = fast_create(Community)
    another_user = create_user("another_user").person

    login_as_rails5(@profile.identifier)

    community.add_admin(@profile)

    assert community.admins.include? @profile
    get members_profile_path(community.identifier)

    assert_tag tag: "ul", attributes: { class: /profile-list-admins/ },
               descendant: { tag: "a", attributes: { title: "testuser" } }

    assert_tag tag: "ul", attributes: { class: /profile-list-members/ },
               descendant: { tag: "a", attributes: { title: "testuser" } }
  end

  should "all members, except admins, be present in members div" do
    community = fast_create(Community)
    community.add_member(@profile)

    another_user = create_user("another_user").person
    community.add_member(another_user)

    assert_equal false, community.admins.include?(another_user)

    get members_profile_path(community.identifier)

    assert_tag tag: "ul", attributes: { class: /profile-list-members/ },
               descendant: { tag: "a", attributes: { title: "another_user" } }

    !assert_tag tag: "ul", attributes: { class: /profile-list-admins/ },
                descendant: { tag: "a", attributes: { title: "another_user" } }
  end

  should "members be sorted by name in ascendant order" do
    community = fast_create(Community)
    another_user = create_user("another_user").person
    different_user = create_user("different_user").person

    community.add_member(@profile)
    community.add_member(another_user)
    community.add_member(different_user)

    get members_profile_path(community.identifier), params: { sort: "asc" }

    assert @response.body.index("another_user") < @response.body.index("different_user")
  end

  should "members be sorted by name in descendant order" do
    community = fast_create(Community)
    another_user = create_user("another_user").person
    different_user = create_user("different_user").person

    community.add_member(@profile)
    community.add_member(another_user)
    community.add_member(different_user)

    get members_profile_path(community.identifier), params: { sort: "desc" }

    assert @response.body.index("another_user") > @response.body.index("different_user")
  end

  should "redirect to login if environment is restrict to members" do
    Environment.default.enable(:restrict_to_members)
    get profile_path(profile.identifier)
    assert_redirected_to controller: "account", action: "login"
  end

  should "not follow a user without defining a circle" do
    login_as_rails5(@profile.identifier)
    person = fast_create(Person)
    assert_no_difference "ProfileFollower.count" do
      post follow_profile_path(person.identifier), params: { circles: {} }
    end
  end

  should "not follow user if not logged" do
    person = fast_create(Person)
    get follow_profile_path(person.identifier)

    assert_redirected_to controller: "account", action: "login"
  end

  should "follow a user with a circle" do
    login_as_rails5(@profile.identifier)
    person = fast_create(Person)

    circle = Circle.create!(person: @profile, name: "Zombies", profile_type: "Person")

    assert_difference "ProfileFollower.count" do
      post follow_profile_path(person.identifier), params: { circles: { "Zombies" => circle.id } }
    end
  end

  should "follow a user with more than one circle" do
    login_as_rails5(@profile.identifier)
    person = fast_create(Person)

    circle = Circle.create!(person: @profile, name: "Zombies", profile_type: "Person")
    circle2 = Circle.create!(person: @profile, name: "Brainsss", profile_type: "Person")

    assert_difference "ProfileFollower.count", 2 do
      post follow_profile_path(person.identifier), params: { circles: { "Zombies" => circle.id, "Brainsss" => circle2.id } }
    end
  end

  should "not follow a user with no circle selected" do
    login_as_rails5(@profile.identifier)
    person = fast_create(Person)

    circle = Circle.create!(person: @profile, name: "Zombies", profile_type: "Person")
    circle2 = Circle.create!(person: @profile, name: "Brainsss", profile_type: "Person")

    assert_no_difference "ProfileFollower.count" do
      post follow_profile_path(person.identifier), params: { circles: { "Zombies" => "0", "Brainsss" => "0" } }
    end

    assert_match /Select at least one circle to follow/, response.body
  end

  should "not follow if current_person already follows the person" do
    login_as_rails5(@profile.identifier)
    person = fast_create(Person)

    circle = Circle.create!(person: @profile, name: "Zombies", profile_type: "Person")
    fast_create(ProfileFollower, profile_id: person.id, circle_id: circle.id)

    assert_no_difference "ProfileFollower.count" do
      post follow_profile_path(person.identifier), params: { follow: { circles: { "Zombies" => circle.id } } }
    end
  end

  should "not unfollow user if not logged" do
    person = fast_create(Person)
    post unfollow_profile_path(person.identifier)

    assert_redirected_to controller: "account", action: "login"
  end

  should "unfollow a followed person" do
    login_as_rails5(@profile.identifier)
    person = fast_create(Person)

    circle = Circle.create!(person: @profile, name: "Zombies", profile_type: "Person")
    follower = fast_create(ProfileFollower, profile_id: person.id, circle_id: circle.id)

    assert_not_nil follower

    post unfollow_profile_path(person.identifier)
    follower = ProfileFollower.find_by(profile_id: person.id, circle_id: circle.id)
    assert_nil follower
  end

  should "not unfollow a not followed person" do
    login_as_rails5(@profile.identifier)
    person = fast_create(Person)

    assert_no_difference "ProfileFollower.count" do
      post unfollow_profile_path(person.identifier)
    end
  end

  should "not display the unfollow button if the person is in the social circle" do
    login_as_rails5(@profile.identifier)
    community = fast_create(Community)
    community.add_member(@profile)

    get profile_path(community.identifier)
    !assert_tag tag: "a", attributes: { id: "action-unfollow" }
  end

  should "redirect to page after unfollow" do
    login_as_rails5(@profile.identifier)
    person = fast_create(Person)

    circle = Circle.create!(person: @profile, name: "Zombies", profile_type: "Person")
    fast_create(ProfileFollower, profile_id: person.id, circle_id: circle.id)

    post unfollow_profile_path(person.identifier), params: { redirect_to: "/some/url" }
    assert_redirected_to "/some/url"
  end

  should "search followed people or circles" do
    login_as_rails5(@profile.identifier)
    c1 = Circle.create!(name: "Family", person: @profile, profile_type: Person)
    c2 = Circle.create!(name: "Work", person: @profile, profile_type: Person)
    p1 = create_user("emily").person
    p2 = create_user("wollie").person
    p3 = create_user("mary").person
    ProfileFollower.create!(profile: p1, circle: c2)
    ProfileFollower.create!(profile: p2, circle: c1)
    ProfileFollower.create!(profile: p3, circle: c1)

    get search_followed_profile_path(profile.identifier), params: { q: "mily" }
    assert_equal "Family (Circle)", json_response[0]["name"]
    assert_equal "Circle", json_response[0]["class"]
    assert_equal "Circle_#{c1.id}", json_response[0]["id"]
    assert_equal "emily (Person)", json_response[1]["name"]
    assert_equal "Person", json_response[1]["class"]
    assert_equal "Person_#{p1.id}", json_response[1]["id"]

    get search_followed_profile_path(profile.identifier), params: { q: "wo" }
    assert_equal "Work (Circle)", json_response[0]["name"]
    assert_equal "Circle", json_response[0]["class"]
    assert_equal "Circle_#{c2.id}", json_response[0]["id"]
    assert_equal "wollie (Person)", json_response[1]["name"]
    assert_equal "Person", json_response[1]["class"]
    assert_equal "Person_#{p2.id}", json_response[1]["id"]

    get search_followed_profile_path(profile.identifier), params: { q: "mar" }
    assert_equal "mary (Person)", json_response[0]["name"]
    assert_equal "Person", json_response[0]["class"]
    assert_equal "Person_#{p3.id}", json_response[0]["id"]
  end

  should "treat followed entries" do
    @controller = ProfileController.new
    c1 = Circle.create!(name: "Family", person: @profile, profile_type: Person)
    p1 = create_user("emily").person
    p2 = create_user("wollie").person
    p3 = create_user("mary").person
    ProfileFollower.create!(profile: p1, circle: c1)
    ProfileFollower.create!(profile: p3, circle: c1)

    entries = "Circle_#{c1.id},Person_#{p1.id},Person_#{p2.id}"
    @controller.stubs(:profile).returns(@profile)
    @controller.stubs(:user).returns(@profile)
    marked_people = @controller.send(:treat_followed_entries, entries)

    assert_equivalent [p1, p2, p3], marked_people
  end

  should "return empty followed entries if the user is not on his wall" do
    @controller = ProfileController.new
    c1 = Circle.create!(name: "Family", person: @profile, profile_type: Person)
    p1 = create_user("emily").person
    p2 = create_user("wollie").person
    p3 = create_user("mary").person
    ProfileFollower.create!(profile: p1, circle: c1)
    ProfileFollower.create!(profile: p3, circle: c1)

    entries = "Circle_#{c1.id},Person_#{p1.id},Person_#{p2.id}"
    @controller.stubs(:profile).returns(@profile)
    @controller.stubs(:user).returns(p1)
    marked_people = @controller.send(:treat_followed_entries, entries)

    assert_empty marked_people
  end

  should "leave private scrap" do
    login_as_rails5(@profile.identifier)
    c1 = Circle.create!(name: "Family", person: @profile, profile_type: Person)
    p1 = create_user("emily").person
    p2 = create_user("wollie").person
    ProfileFollower.create!(profile: p1, circle: c1)
    ProfileFollower.create!(profile: p2, circle: c1)

    content = "Remember my birthday!"

    post leave_scrap_profile_path(@profile.identifier), params: { scrap: { content: content }, filter_followed: "Person_#{p1.id},Person_#{p2.id}" }

    scrap = Scrap.last
    assert_equal content, scrap.content
    assert_equivalent [p1, p2], scrap.marked_people
  end

  should "list private scraps on wall for marked people" do
    c1 = Circle.create!(name: "Family", person: @profile, profile_type: Person)
    p1 = create_user("emily").person
    ProfileFollower.create!(profile: p1, circle: c1)
    p1.add_friend(@profile)
    scrap = Scrap.create!(content: "Secret message.", sender_id: @profile.id, receiver_id: @profile.id, marked_people: [p1])
    scrap_activity = ProfileActivity.where(activity: scrap).first
    login_as_rails5(p1.identifier)

    get profile_path(@profile.identifier)

    assert assigns(:activities).include?(scrap_activity)
  end

  should "not list private scraps on wall for not marked people" do
    c1 = Circle.create!(name: "Family", person: @profile, profile_type: Person)
    p1 = create_user("emily").person
    p2 = create_user("wollie").person
    not_marked = create_user("jack").person
    not_marked.add_friend(@profile)
    ProfileFollower.create!(profile: p1, circle: c1)
    ProfileFollower.create!(profile: p2, circle: c1)
    ProfileFollower.create!(profile: not_marked, circle: c1)
    scrap = Scrap.create!(content: "Secret message.", sender_id: @profile.id, receiver_id: @profile.id, marked_people: [p1, p2])
    scrap_activity = ProfileActivity.where(activity: scrap).first
    login_as_rails5(not_marked.identifier)

    get profile_path(@profile.identifier)

    assert !assigns(:activities).include?(scrap_activity)
  end

  should "list private scraps on wall for creator" do
    c1 = Circle.create!(name: "Family", person: @profile, profile_type: Person)
    p1 = create_user("emily").person
    ProfileFollower.create!(profile: p1, circle: c1)
    scrap = Scrap.create!(content: "Secret message.", sender_id: @profile.id, receiver_id: @profile.id, marked_people: [p1])
    scrap_activity = ProfileActivity.where(activity: scrap).first
    login_as_rails5(@profile.identifier)

    get profile_path(@profile.identifier)

    assert assigns(:activities).include?(scrap_activity)
  end

  should "list private scraps on wall for environment administrator" do
    c1 = Circle.create!(name: "Family", person: @profile, profile_type: Person)
    p1 = create_user("emily").person
    admin = create_user("env-admin").person
    env = @profile.environment
    env.add_admin(admin)
    admin.add_friend(@profile)
    ProfileFollower.create!(profile: p1, circle: c1)
    scrap = Scrap.create!(content: "Secret message.", sender_id: @profile.id, receiver_id: @profile.id, marked_people: [p1])
    scrap_activity = ProfileActivity.where(activity: scrap).first
    login_as_rails5(admin.identifier)

    get profile_path(@profile.identifier)

    assert assigns(:activities).include?(scrap_activity)
  end

  should "not fetch or show wall activities if user does not have wall access" do
    sample_user = create_user("sample-user").person
    login_as_rails5(sample_user.identifier)
    Profile.any_instance.stubs(:display_to?).returns(false)
    get profile_path(@profile.identifier)
    assert_nil assigns(:activities)
    !assert_tag tag: "div", attributes: { id: "profile-wall" }
  end

  should "fetch and show wall activities if user has wall access" do
    sample_user = create_user("sample-user").person
    login_as_rails5(sample_user.identifier)
    Profile.any_instance.stubs(:display_to?).returns(true)
    get profile_path(@profile.identifier)
    assert_not_nil assigns(:activities)
    assert_tag tag: "div", attributes: { id: "profile-wall" }
  end

  should "not fetch or show network activities for visitor" do
    get profile_path(@profile.identifier)
    assert_nil assigns(:network_activities)
    !assert_tag tag: "div", attributes: { id: "profile-network" }
  end

  should "not fetch or show network activities for logged users" do
    sample_user = create_user("sample-user").person
    login_as_rails5(sample_user.identifier)
    get profile_path(@profile.identifier)
    assert_nil assigns(:network_activities)
    !assert_tag tag: "div", attributes: { id: "profile-network" }
  end

  should "not fetch or show network activities for friends" do
    friend = create_user("friend").person
    friend.add_friend(@profile)
    login_as_rails5(friend.identifier)
    get profile_path(@profile.identifier)
    assert_nil assigns(:network_activities)
    !assert_tag tag: "div", attributes: { id: "profile-network" }
  end

  should "fetch and show network activities for the user" do
    login_as_rails5(@profile.identifier)
    get profile_path(@profile.identifier)
    assert_not_nil assigns(:network_activities)
    assert_tag tag: "div", attributes: { id: "profile-network" }
  end

  should "display comments of an article in network activities tab" do
    login_as_rails5(profile.identifier)
    article = TextArticle.create!(profile: profile, name: "An article about free software")
    20.times do |i|
      comment = fast_create(Comment, source_id: article, title: "Comment #{i}",
                                     body: "lalala", created_at: Time.now)
    end
    assert_equal 20, article.comments.count
    activity = ActionTracker::Record.last
    get more_comments_profile_path(profile.identifier), params: { activity: activity.id, comment_page: 1, tab_action: "network" }, xhr: true
    assert_response :success
    assert_template "_comment"
    assert_select "li", 5 # 5 comments per page
  end

  should "not filter any activity if the user is an environment admin" do
    @controller = ProfileController.new
    admin = create_user("env-admin").person
    env = @profile.environment
    env.add_admin(admin)
    activities = mock
    activities.expects(:delete_if).never
    @controller.stubs(:user).returns(admin)
    @controller.stubs(:environment).returns(env)
    @controller.send(:filter_activities, activities, :wall)
  end

  should "not call hidden_for? if the user is involved in the activity" do
    @controller = ProfileController.new
    user = create_user("involved-user").person
    env = @profile.environment
    activity = mock
    activities = [activity]
    activity.stubs(:involved?).with(user).returns(true)
    activity.expects(:hidden_for?).never
    @controller.stubs(:user).returns(user)
    @controller.stubs(:environment).returns(env)
    result = @controller.send(:filter_activities, activities, :wall)
    assert_includes result, activity
  end

  should "remove activities that should be hidden for the user" do
    @controller = ProfileController.new
    user = create_user("sample-user").person
    env = @profile.environment
    a1 = mock
    a2 = mock
    a3 = mock
    activities = [a1, a2, a3]
    a1.stubs(:involved?).with(user).returns(false)
    a2.stubs(:involved?).with(user).returns(false)
    a3.stubs(:involved?).with(user).returns(false)
    a1.stubs(:hidden_for?).with(user).returns(false)
    a2.stubs(:hidden_for?).with(user).returns(true)
    a3.stubs(:hidden_for?).with(user).returns(false)
    @controller.stubs(:user).returns(user)
    @controller.stubs(:environment).returns(env)
    result = @controller.send(:filter_activities, activities, :wall)
    assert_equivalent [a1, a3], result
  end

  should "display about" do
    get about_profile_path(profile.identifier)

    assert_response :success
    assert_template "about"
  end

  should "display profile tags in about" do
    Person.any_instance.stubs(:article_tags).returns("first profile tag" => 1, "second profile tag" => 2)
    get about_profile_path(profile.identifier)
    assert_response :success
    assert_template "about"
    assert_match /first profile tag/, @response.body
    assert_match /second profile tag/, @response.body
  end

  should "display activities" do
    p1 = create_user("test").person
    40.times { create(Scrap, sender: p1, receiver: p1, created_at: Time.now) }

    login_as_rails5(p1.identifier)

    get activities_profile_path(p1.identifier)
    assert_response :success
    assert_template "activities"
    assert assigns(:activities)
  end

  should "follow a community after creating it" do
    user = create_user("sample-user").person
    community = Community.create!(name: "my test community")
    community.add_admin(user)

    assert community.followed_by? user
  end

  should "follow an enterprise after creating it" do
    user = create_user("sample-user").person
    enterprise = Enterprise.create!(name: "my test enterprise", identifier: "my-test-enterprise")
    enterprise.add_admin(user)

    assert enterprise.followed_by? user
  end

  should "send a push notification to the scrap receiver" do
    login_as_rails5(profile.identifier)
    another_person = create_user.person

    another_person.push_subscriptions.create(endpoint: "/some",
                                             keys: { auth: "1", p256dh: "2" })

    post leave_scrap_profile_path(another_person.identifier), params: { scrap: { content: "something" } }
    Webpush.expects(:payload_send).once
    process_delayed_job_queue
  end
end
