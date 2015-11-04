require_relative "../test_helper"

class CommunityTest < ActiveSupport::TestCase

  def setup
    @person = fast_create(Person)
  end

  attr_reader :person

  should 'inherit from Profile' do
    assert_kind_of Profile, Community.new
  end

  should 'convert name into identifier' do
    c = Community.new
    c.name ='My shiny new Community'
    assert_equal 'My shiny new Community', c.name
    assert_equal 'my-shiny-new-community', c.identifier
  end

  should 'have a description attribute' do
    c = build(Community, :environment => Environment.default)
    c.description = 'the description of the community'
    assert_equal 'the description of the community', c.description
  end

  should 'create default set of blocks' do
    c = create(Community, :environment => Environment.default, :name => 'my new community')

    refute c.boxes[0].blocks.empty?, 'person must have blocks in area 1'
    refute c.boxes[1].blocks.empty?, 'person must have blocks in area 2'
    refute c.boxes[2].blocks.empty?, 'person must have blocks in area 3'
  end

  should 'create a default set of articles' do
    blog = build(Blog)
    Community.any_instance.stubs(:default_set_of_articles).returns([blog])
    community = create(Community, :environment => Environment.default, :name => 'my new community')

    assert_kind_of Blog, community.articles.find_by_path(blog.path)
    assert community.articles.find_by_path(blog.path).published?
    assert_kind_of RssFeed, community.articles.find_by_path(blog.feed.path)
    assert community.articles.find_by_path(blog.feed.path).published?
  end

  should 'have contact_person' do
    community = build(Community, :environment => Environment.default, :name => 'my new community')
    assert_respond_to community, :contact_person
  end

  should 'allow to add new members' do
    c = fast_create(Community, :name => 'my test profile', :identifier => 'mytestprofile')
    p = create_user('mytestuser').person

    c.add_member(p)

    assert c.members.include?(p), "Community should add the new member"
  end

  should 'allow to remove members' do
    c = fast_create(Community, :name => 'my other test profile', :identifier => 'myothertestprofile')
    p = create_user('myothertestuser').person

    c.add_member(p)
    assert_includes c.members, p
    c.remove_member(p)
    c.reload
    assert_not_includes c.members, p
  end

  should 'clear relationships after destroy' do
    c = fast_create(Community, :name => 'my test profile', :identifier => 'mytestprofile')
    member = create_user('memberuser').person
    admin = create_user('adminuser').person
    moderator = create_user('moderatoruser').person

    c.add_member(member)
    c.add_admin(admin)
    c.add_moderator(moderator)

    relationships = c.role_assignments
    assert_not_nil relationships

    c.destroy
    relationships.each do |i|
      refute RoleAssignment.exists?(i.id)
    end
  end

  should 'have a community template' do
    template = fast_create(Community, :is_template => true)
    p = create(Community, :name => 'test_com', :identifier => 'test_com', :template => template)
    assert_equal template, p.template
  end

  should 'have a default community template' do
    env = create(Environment, :name => 'test env')
    p = create(Community, :name => 'test_com', :identifier => 'test_com', :environment => env)
    assert_kind_of Community, p.template
  end

  should 'return active_community_fields' do
    e = Environment.default
    e.expects(:active_community_fields).returns(['contact_phone', 'contact_email']).at_least_once
    ent = build(Community, :environment => e)

    assert_equal e.active_community_fields, ent.active_fields
  end

  should 'return required_community_fields' do
    e = Environment.default
    e.expects(:required_community_fields).returns(['contact_phone', 'contact_email']).at_least_once
    community = build(Community, :environment => e)

    assert_equal e.required_community_fields, community.required_fields
  end

  should 'require fields if community needs' do
    e = Environment.default
    e.expects(:required_community_fields).returns(['contact_phone']).at_least_once
    community = build(Community, :name => 'My community', :environment => e)
    refute  community.valid?
    assert community.errors[:contact_phone.to_s].present?

    community.contact_phone = '99999'
    community.valid?
    refute  community.errors[:contact_phone.to_s].present?
  end

  should 'not require fields if community is a template' do
    e = Environment.default
    e.expects(:required_community_fields).returns(['contact_phone']).at_least_once
    community = build(Community, :name => 'My community', :environment => e)
    refute  community.valid?
    assert community.errors[:contact_phone.to_s].present?

    community.is_template = true
    community.valid?
    refute  community.errors[:contact_phone.to_s].present?
  end

  should 'return newest text articles as news' do
    c = fast_create(Community, :name => 'test_com')
    f = fast_create(Folder, :name => 'folder', :profile_id => c.id)
    u = create(UploadedFile, :profile => c, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    older_t = fast_create(TinyMceArticle, :name => 'old news', :profile_id => c.id)
    t = fast_create(TinyMceArticle, :name => 'news', :profile_id => c.id)
    t_in_f = fast_create(TinyMceArticle, :name => 'news', :profile_id => c.id, :parent_id => f.id)

    assert_equal [t_in_f, t], c.news(2)
  end

  should 'not return highlighted news when not asked' do
    c = fast_create(Community, :name => 'test_com')
    highlighted_t = fast_create(TinyMceArticle, :name => 'high news', :profile_id => c.id, :highlighted => true)
    t = fast_create(TinyMceArticle, :name => 'news', :profile_id => c.id)

    assert_equal [t].map(&:slug), c.news(2).map(&:slug)
  end

  should 'return highlighted news when asked' do
    c = fast_create(Community, :name => 'test_com')
    highlighted_t = fast_create(TinyMceArticle, :name => 'high news', :profile_id => c.id, :highlighted => true)
    t = fast_create(TinyMceArticle, :name => 'news', :profile_id => c.id)

    assert_equal [highlighted_t].map(&:slug), c.news(2, true).map(&:slug)
  end

  should 'sanitize description' do
    c = create(Community, :name => 'test_com', :description => '<b>new</b> community')

    assert_sanitized c.description
  end

  should 'sanitize name' do
    c = create(Community, :name => '<b>test_com</b>')

    assert_sanitized c.name
  end

  should 'create a task when creating a community if feature is enabled' do
    env = Environment.default
    env.enable('admin_must_approve_new_communities')
    person.stubs(:notification_emails).returns(['sample@example.org'])

    assert_difference 'CreateCommunity.count' do
      Community.create_after_moderation(person, {:environment => env, :name => 'Example'})
    end

    assert_no_difference 'Community.count' do
      Community.create_after_moderation(person, {:environment => env, :name => 'Example'})
    end
  end

  should 'create a community if feature is disabled' do
    env = Environment.default
    env.disable('admin_must_approve_new_communities')

    assert_difference 'Community.count' do
      Community.create_after_moderation(person, {:environment => env, :name => 'Example 1'})
    end

    assert_no_difference 'CreateCommunity.count' do
      Community.create_after_moderation(person, {:environment => env, :name => 'Example 2'})
    end
  end

  should 'set as member without task if organization is closed and has no members' do
    community = fast_create(Community)
    community.closed = true
    community.save

    assert_no_difference 'AddMember.count' do
      community.add_member(person)
    end
    assert person.is_member_of?(community)
  end

  should 'set as member without task if organization is not closed and has no members' do
    community = fast_create(Community)

    assert_no_difference 'AddMember.count' do
      community.add_member(person)
    end
    assert person.is_member_of?(community)
  end

  should 'not create new request membership if it already exists' do
    community = fast_create(Community)
    community.closed = true
    community.save
    community.add_member(fast_create(Person))
    community.reload

    community.stubs(:notification_emails).returns(['sample@example.org'])

    assert_difference 'AddMember.count' do
      community.add_member(person)
    end

    assert_no_difference 'AddMember.count' do
      community.add_member(person)
    end
  end

  should "the followed_by method be protected and true to the community members by default" do
    c = fast_create(Community)
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)

    refute p1.is_member_of?(c)
    c.add_member(p1)
    assert p1.is_member_of?(c)

    refute p3.is_member_of?(c)
    c.add_member(p3)
    assert p3.is_member_of?(c)

    assert_equal true, c.send(:followed_by?,p1)
    assert_equal true, c.send(:followed_by?,p3)
    assert_equal false, c.send(:followed_by?,p2)
  end

  should "be created an tracked action when the user is join to the community" do
    p1 = Person.first
    community = fast_create(Community)
    p2 = fast_create(Person)
    p3 = fast_create(Person)

    RoleAssignment.delete_all
    ActionTrackerNotification.delete_all
    assert_difference 'ActionTrackerNotification.count', 5 do
      community.add_member(p1)
      process_delayed_job_queue
      community.add_member(p3)
      assert p1.is_member_of?(community)
      refute p2.is_member_of?(community)
      assert p3.is_member_of?(community)
      process_delayed_job_queue
    end
    ActionTrackerNotification.all.map{|a|a.profile}.map do |profile|
      assert [community,p1,p3].include?(profile)
    end
  end

  should "update the action of article creation when an community's article is commented" do
    ActionTrackerNotification.delete_all
    p1 = Person.first
    community = fast_create(Community)
    p2 = create_user.person
    p3 = create_user.person
    community.add_member(p3)
    article = create(TextileArticle, :profile_id => community.id)
    time = article.activity.updated_at + 1.day
    Time.stubs(:now).returns(time)
    create(Comment, :source_id => article.id, :title => 'some', :body => 'some', :author_id => p2.id)
    process_delayed_job_queue
    assert_equal time, article.activity.updated_at
  end

  should "see get all received scraps" do
    c = fast_create(Community)
    assert_equal [], c.scraps_received
    fast_create(Scrap, :receiver_id => c.id)
    fast_create(Scrap, :receiver_id => c.id)
    assert_equal 2, c.scraps_received.count
    c2 = fast_create(Community)
    fast_create(Scrap, :receiver_id => c2.id)
    assert_equal 2, c.scraps_received.count
    fast_create(Scrap, :receiver_id => c.id)
    assert_equal 3, c.scraps_received.count
  end

  should "see get all received scraps that are not replies" do
    c = fast_create(Community)
    s1 = fast_create(Scrap, :receiver_id => c.id)
    s2 = fast_create(Scrap, :receiver_id => c.id)
    s3 = fast_create(Scrap, :receiver_id => c.id, :scrap_id => s1.id)
    assert_equal 3, c.scraps_received.count
    assert_equal [s1,s2], c.scraps_received.not_replies
    c2 = fast_create(Community)
    s4 = fast_create(Scrap, :receiver_id => c2.id)
    s5 = fast_create(Scrap, :receiver_id => c2.id, :scrap_id => s4.id)
    assert_equal 2, c2.scraps_received.count
    assert_equal [s4], c2.scraps_received.not_replies
  end

  should "the community browse for a scrap with a Scrap object" do
    c = fast_create(Community)
    s1 = fast_create(Scrap, :receiver_id => c.id)
    s2 = fast_create(Scrap, :receiver_id => c.id)
    s3 = fast_create(Scrap, :receiver_id => c.id)
    assert_equal s2, c.scraps(s2)
  end

  should "the person browse for a scrap with an integer and string id" do
    c = fast_create(Community)
    s1 = fast_create(Scrap, :receiver_id => c.id)
    s2 = fast_create(Scrap, :receiver_id => c.id)
    s3 = fast_create(Scrap, :receiver_id => c.id)
    assert_equal s2, c.scraps(s2.id)
    assert_equal s2, c.scraps(s2.id.to_s)
  end

  should 'receive scrap notification' do
    community = fast_create(Community)
    assert_equal false, community.receives_scrap_notification?
  end

  should 'return scraps as activities' do
    person = fast_create(Person)
    community = fast_create(Community)

    scrap = create(Scrap, defaults_for_scrap(:sender => person, :receiver => community, :content => 'A scrap'))
    activity = ActionTracker::Record.last

    assert_equal [scrap], community.activities.map(&:activity)
  end

  should 'return tracked_actions of community as activities' do
    person = create_user.person
    community = fast_create(Community)

    User.current = person.user
    assert_difference 'ActionTracker::Record.count', 1 do
      article = create(TinyMceArticle, :profile => community, :name => 'An article about free software')
      assert_equal [article.activity], community.activities.map(&:activity)
    end
  end

  should 'not return tracked_actions of other community as activities' do
    person = fast_create(Person)
    community = fast_create(Community)
    community2 = fast_create(Community)

    User.current = person.user
    article = create(TinyMceArticle, :profile => community2, :name => 'Another article about free software')

    assert_not_includes community.activities.map { |a| a.klass.constantize.find(a.id) }, article.activity
  end


  should 'check if a community admin user is really a community admin' do
    c = fast_create(Community, :name => 'my test profile', :identifier => 'mytestprofile')
    admin = create_user('adminuser').person
    c.add_admin(admin)

    assert c.is_admin?(admin)
  end

  should 'a member user not be a community admin' do
    c = fast_create(Community, :name => 'my test profile', :identifier => 'mytestprofile')
    admin = create_user('adminuser').person
    c.add_admin(admin)

    member = create_user('memberuser').person
    c.add_member(member)
    refute c.is_admin?(member)
  end

  should 'a moderator user not be a community admin' do
    c = fast_create(Community, :name => 'my test profile', :identifier => 'mytestprofile')
    moderator = create_user('moderatoruser').person
    c.add_moderator(moderator)
    refute c.is_admin?(moderator)
  end

end
