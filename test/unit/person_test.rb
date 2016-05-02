# encoding: UTF-8
require_relative "../test_helper"

class PersonTest < ActiveSupport::TestCase
  fixtures :profiles, :users, :environments

  def test_person_must_come_from_the_creation_of_an_user
    p = build(Person, :environment => Environment.default, :name => 'John', :identifier => 'john')
    refute p.valid?
    p.user =  create_user('john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe')
    refute p.valid?
    p = create_user('johnz', :email => 'johnz@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    assert p.valid?
  end

  def test_can_associate_to_a_profile
    pr = build(Profile, :identifier => 'mytestprofile', :name => 'My test profile')
    pr.save!
    pe = create_user('person', :email => 'person@test.net', :password => 'dhoe', :password_confirmation => 'dhoe').person
    pe.save!
    member_role = create(Role, :name => 'somerandomrole')
    pr.affiliate(pe, member_role)

    assert pe.memberships.include?(pr)
  end

  def test_can_belong_to_an_enterprise
    e = build(Enterprise, :identifier => 'enterprise', :name => 'enterprise')
    e.save!
    p = create_user('person', :email => 'person@test.net', :password => 'dhoe', :password_confirmation => 'dhoe').person
    p.save!
    member_role = create(Role, :name => 'somerandomrole')
    e.affiliate(p, member_role)

    assert p.memberships.include?(e)
    assert p.enterprises.include?(e)
  end

  should 'belong to communities' do
    c = fast_create(Community)
    p = create_user('mytestuser').person

    c.add_member(p)

    assert p.communities.include?(c), "Community should add a new member"
  end

  should 'be associated with a user' do
    u = build(User, :login => 'john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe')
    u.save!
    assert_equal u, Person['john'].user
  end

  should 'only one person per user' do
    u = create_user('john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe')

    p1 = u.person
    assert_equal u, p1.user

    p2 = build(Person, :environment => Environment.default)
    p2.user = u
    refute p2.valid?
    assert p2.errors[:user_id.to_s].present?
  end

  should "have person info fields" do
    p = build(Person, :environment => Environment.default)
    [ :name, :photo, :contact_information, :birth_date, :sex, :address, :city, :state, :country, :zip_code, :image, :district, :address_reference ].each do |i|
      assert_respond_to p, i
    end
  end

  should 'not have person_info class' do
    p = build(Person, :environment => Environment.default)
    assert_raise NoMethodError do
      p.person_info
    end
  end

  should 'change the roles of the user' do
    p = create_user('jonh', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    e = fast_create(Enterprise)
    r1 = create(Role, :name => 'associate')
    assert e.affiliate(p, r1)
    r2 = create(Role, :name => 'partner')
    assert p.define_roles([r2], e)
    p = Person.find(p.id)
    assert p.role_assignments.any? {|ra| ra.role == r2}
    refute p.role_assignments.any? {|ra| ra.role == r1}
  end

  should 'report that the user has the permission' do
    p = create_user('john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    r = create(Role, :name => 'associate', :permissions => ['edit_profile'])
    e = fast_create(Enterprise)
    assert e.affiliate(p, r)
    p = Person.find(p.id)
    assert e.reload
    assert p.has_permission?('edit_profile', e)
    refute p.has_permission?('destroy_profile', e)
  end

  should 'get an email address from the associated user instance' do
    p = create_user('jonh', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    assert_equal 'john@doe.org', p.email
  end

  should 'get no email address when there is no associated user' do
    p = build(Person, :environment => Environment.default)
    assert_nil p.email
  end

  should 'use email addreess as contact email' do
    p = Person.new
    p.stubs(:email).returns('my@email.com')
    assert_equal 'my@email.com', p.contact_email
  end

  should 'set email through person instance' do
    u = create_user('testuser')
    p = u.person

    p.email = 'damnit@example.com'
    p.save!

    u.reload
    assert_equal 'damnit@example.com', u.email
  end

  should 'not be able to change e-mail to an e-mail of other user' do
    create_user('firstuser', :email => 'user@domain.com')

    other = create_user('seconduser', :email => 'other@domain.com').person
    other.email = 'user@domain.com'
    other.valid?
    assert other.errors[:email.to_s].present?
    assert_no_match /\{fn\}/, other.errors[:email].first
  end

  should 'be able to use an e-mail already used in other environment' do
    first = create_user('user', :email => 'user@example.com')

    other_env = fast_create(Environment)
    other = create_user('user', :email => 'other@example.com', :environment => other_env).person
    other.email = 'user@example.com'
    other.valid?
    refute other.errors[:email.to_s].present?
  end

  should 'be an admin if have permission of environment administration' do
    role = create(Role, :name => 'just_another_admin_role')
    env = fast_create(Environment)
    person = create_user('just_another_person').person
    env.affiliate(person, role)
    refute  person.is_admin?(env)
    role.update(:permissions => ['view_environment_admin_panel'])
    person = Person.find(person.id)
    assert person.is_admin?(env)
  end

  should 'separate admins of different environments' do
    env1 = fast_create(Environment)
    env2 = fast_create(Environment)

    # role is an admin role
    role = create(Role, :name => 'just_another_admin_role')
    role.update(:permissions => ['view_environment_admin_panel'])

    # user is admin of env1, but not of env2
    person = create_user('just_another_person').person
    env1.affiliate(person, role)

    person = Person.find(person.id)
    assert person.is_admin?(env1)
    refute person.is_admin?(env2)
  end

  should 'create a default set of articles' do
    blog = build(Blog)
    Person.any_instance.stubs(:default_set_of_articles).returns([blog])
    person = create(User).person

    assert_kind_of Blog, person.articles.find_by(path: blog.path)
    assert person.articles.find_by(path: blog.path).published?
    assert_kind_of RssFeed, person.articles.find_by(path: blog.feed.path)
    assert person.articles.find_by(path: blog.feed.path).published?
  end

  should 'create a default set of blocks' do
    p = create(User).person

    refute p.boxes[0].blocks.empty?, 'person must have blocks in area 1'
    refute p.boxes[1].blocks.empty?, 'person must have blocks in area 2'
    refute p.boxes[2].blocks.empty?, 'person must have blocks in area 3'
  end

  should 'link to all articles created by default' do
    p = create(User).person
    blocks = p.blocks.select { |b| b.is_a?(LinkListBlock) }
    p.articles.reject { |a| a.is_a?(RssFeed) }.each do |article|
      path = '/' + p.identifier + '/' + article.path
      assert blocks.any? { |b| b.links.any? { |link| b.expand_address(link[:address]) == path  }}, "#{path.inspect} must be linked by at least one of the blocks: #{blocks.inspect}"
    end
  end

  should 'have friends' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    p1.add_friend(p2)

    p1.friends.reload
    assert_equal [p2], p1.friends

    p3 = create_user('testuser3').person
    p1.add_friend(p3)

    assert_equivalent [p2,p3], p1.friends(true) # force reload
  end

  should 'suggest default friend groups list' do
    p = build(Person, :environment => Environment.default)
    assert_equivalent [ 'friends', 'work', 'school', 'family' ], p.suggested_friend_groups
  end

  should 'suggest current groups as well' do
    p = build(Person, :environment => Environment.default)
    p.expects(:friend_groups).returns(['group1', 'group2'])
    assert_equivalent [ 'friends', 'work', 'school', 'family', 'group1', 'group2' ], p.suggested_friend_groups
  end

  should 'accept nil friend groups when suggesting friend groups' do
    p = build(Person, :environment => Environment.default)
    p.expects(:friend_groups).returns([nil])
    assert_equivalent [ 'friends', 'work', 'school', 'family' ], p.suggested_friend_groups
  end

  should 'list friend groups' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    p3 = create_user('testuser3').person
    p4 = create_user('testuser4').person

    p1.add_friend(p2, 'group1')
    p1.add_friend(p3, 'group2')
    p1.add_friend(p4, 'group1')

    assert_equivalent ['group1', 'group2'], p1.friend_groups
  end

  should 'not suggest duplicated friend groups' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person

    p1.add_friend(p2, 'friends')

    assert_equal p1.suggested_friend_groups, p1.suggested_friend_groups.uniq
  end

  should 'remove friend' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    p1.add_friend(p2, 'friends')

    assert_difference 'Friendship.count', -1 do
      p1.remove_friend(p2)
    end
    assert_not_includes p1.friends(true), p2
  end

  should 'destroy friendships when person is destroyed' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    p1.add_friend(p2, 'friends')
    p2.add_friend(p1, 'friends')

    assert_difference 'Friendship.count', -2 do
      p1.destroy
    end
    assert_not_includes p2.friends(true), p1
  end

  should 'destroy use when person is destroyed' do
    person = create_user('testuser').person
    assert_difference 'User.count', -1 do
      person.destroy
    end
  end

  should 'return info name instead of name when info is setted' do
    p = create_user('ze_maria').person
    assert_equal 'ze_maria', p.name
    p.name = 'José'
    assert_equal 'José', p.name
  end

  should 'have favorite enterprises' do
    p = create_user('test_person').person
    e = fast_create(Enterprise)

    p.favorite_enterprises << e

    assert_includes Person.find(p.id).favorite_enterprises, e
  end

  should 'save info contact_information field' do
    person = create_user('new_person').person
    person.contact_information = 'my contact'
    person.save!
    assert_equal 'my contact', person.contact_information
  end

  should 'provide desired info fields' do
    p = build(Person, :environment => Environment.default)
    assert p.respond_to?(:photo)
    assert p.respond_to?(:address)
    assert p.respond_to?(:contact_information)
  end

  should 'required name' do
    person = Person.new
    refute person.valid?
    assert person.errors[:name].present?
  end

  should 'already request friendship' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    create(AddFriend, person: p1, friend: p2).finish
    refute p1.already_request_friendship?(p2)
    create(AddFriend, person: p1, friend: p2)
    assert p1.already_request_friendship?(p2)
  end

  should 'have e-mail addresses' do
    env = fast_create(Environment)
    env.domains <<  build(Domain, :name => 'somedomain.com')
    person = build(Person, :environment => env, :identifier => 'testuser')
    person.expects(:environment).returns(env)

    assert_equal ['testuser@somedomain.com'], person.email_addresses
  end

  should 'not show www in e-mail addresses when force_www=true' do
    env = fast_create(Environment)
    env.domains <<  build(Domain, :name => 'somedomain.com')
    env.update_attribute(:force_www, true)
    person = build(Person, :environment => env, :identifier => 'testuser')
    person.expects(:environment).returns(env)

    assert_equal ['testuser@somedomain.com'], person.email_addresses
  end

  should 'show profile info to friend' do
    person = create_user('test_user').person
    person.public_profile = false
    person.save!
    friend = create_user('test_friend').person
    person.add_friend(friend)
    person.friends.reload
    assert person.display_info_to?(friend)
  end

  should 'have a person template' do
    template = fast_create(Person, :is_template => true)
    p = create_user('test_user').person
    p.template_id = template.id
    p.save!
    assert_equal template, p.template
  end

  should 'have a default person template' do
    env = create(Environment, :name => 'test env')
    p = create_user('test_user', :environment => env).person
    assert_kind_of Person, p.template
  end

  should 'destroy all task that it requested when destroyed' do
    p = create_user('test_profile').person

    assert_no_difference 'Task.count' do
      create(Task, :requestor => p)
      p.destroy
    end
  end

  should 'person has pending tasks' do
    p1 = create_user('user_with_tasks').person
    p1.tasks << Task.new
    p2 = create_user('user_without_tasks').person
    assert_includes Person.with_pending_tasks, p1
    assert_not_includes Person.with_pending_tasks, p2
  end

  should 'person has group with pending tasks' do
    p1 = create_user('user_with_tasks').person
    c1 = fast_create(Community)
    c1.tasks << Task.new
    refute c1.tasks.pending.empty?
    c1.add_admin(p1)

    c2 = fast_create(Community)
    p2 = create_user('user_without_tasks').person
    c2.add_admin(p2)

    assert_includes Person.with_pending_tasks, p1
    assert_not_includes Person.with_pending_tasks, p2
  end

  should 'not allow simple member to view group pending tasks' do
    community = fast_create(Community)
    admin = fast_create(Person)
    community.add_member(admin)
    member = fast_create(Person)
    community.reload
    community.add_member(member)
    community.tasks << Task.new

    assert_not_includes Person.with_pending_tasks, member
  end

  should 'person has organization pending tasks' do
    c = fast_create(Community)
    c.tasks << Task.new
    p = create_user('user_with_tasks').person
    c.add_admin(p)

    assert p.has_organization_pending_tasks?
  end

  should 'select organization pending tasks' do
    c = fast_create(Community)
    c.tasks << Task.new
    p = create_user('user_with_tasks').person
    c.add_admin(p)

    assert_equal p.pending_tasks_for_organization(c), c.tasks
  end

  should 'return active_person_fields' do
    e = Environment.default
    e.expects(:active_person_fields).returns(['cell_phone', 'comercial_phone']).at_least_once
    person = build(Person, :environment => e)

    assert_equal e.active_person_fields, person.active_fields
  end

  should 'return email as active_person_fields' do
    e = Environment.default
    e.expects(:active_person_fields).returns(['nickname']).at_least_once
    person = build(Person, :environment => e)

    assert_equal ['nickname', 'email'], person.active_fields
  end

  should 'return required_person_fields' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['cell_phone', 'comercial_phone']).at_least_once
    person = build(Person, :environment => e)

    assert_equal e.required_person_fields, person.required_fields
  end

  should 'require fields if person needs' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['cell_phone']).at_least_once
    person = build(Person, :environment => e)
    refute  person.valid?
    assert person.errors[:cell_phone.to_s].present?

    person.cell_phone = '99999'
    person.valid?
    refute  person.errors[:cell_phone.to_s].present?
  end

  should 'require custom_area_of_study if area_of_study is others' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['area_of_study', 'custom_area_of_study']).at_least_once

    person = build(Person, :environment => e, :area_of_study => 'Others')
    refute person.valid?
    assert person.errors[:custom_area_of_study.to_s].present?

    person.custom_area_of_study = 'Customized area of study'
    person.valid?
    refute  person.errors[:custom_area_of_study.to_s].present?
  end

  should 'not require custom_area_of_study if area_of_study is not others' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['area_of_study']).at_least_once

    person = build(Person, :environment => e, :area_of_study => 'Agrometeorology')
    person.valid?
    refute  person.errors[:custom_area_of_study.to_s].present?
  end

  should 'require custom_formation if formation is others' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['formation', 'custom_formation']).at_least_once

    person = build(Person, :environment => e, :formation => 'Others')
    refute person.valid?
    assert person.errors[:custom_formation.to_s].present?

    person.custom_formation = 'Customized formation'
    person.valid?
    refute  person.errors[:custom_formation.to_s].present?
  end

  should 'not require custom_formation if formation is not others' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['formation']).at_least_once

    person = build(Person, :environment => e, :formation => 'Agrometeorology')
    refute person.valid?
    refute  person.errors[:custom_formation.to_s].present?
  end

  should 'not require fields if person is a template' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['cell_phone']).at_least_once
    person = build(Person, :environment => e)
    refute  person.valid?
    assert person.errors[:cell_phone.to_s].present?

    person.is_template = true
    person.valid?
    refute  person.errors[:cell_phone.to_s].present?
  end

  should 'identify when person is a friend' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    p1.add_friend(p2)
    p1.friends.reload
    assert p1.is_a_friend?(p2)
  end

  should 'identify when person isnt a friend' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    refute p1.is_a_friend?(p2)
  end

  should 'refuse join community' do
    p = create_user('test_user').person
    c = fast_create(Community)

    assert p.ask_to_join?(c)
    p.refuse_join(c)
    refute p.ask_to_join?(c)
  end

  should 'not ask to join for a member' do
    p = create_user('test_user').person
    c = fast_create(Community)
    c.add_member(p)

    refute p.ask_to_join?(c)
  end

  should 'not ask to join if already asked' do
    p = create_user('test_user').person
    c = fast_create(Community)
    create(AddMember, :person => p, :organization => c)

    refute p.ask_to_join?(c)
  end

  should 'ask to join if community is not public' do
    person = fast_create(Person)
    community = fast_create(Community, :public_profile => false)

    assert person.ask_to_join?(community)
  end

  should 'not ask to join if community is not visible' do
    person = fast_create(Person)
    community = fast_create(Community, :visible => false)

    refute person.ask_to_join?(community)
  end

  should 'save organization_website with http' do
    p = create_user('person_test').person
    p.organization_website = 'website.without.http'
    p.save
    assert_equal 'http://website.without.http', p.organization_website
  end

  should 'not add protocol for empty organization website' do
    p = create_user('person_test').person
    p.organization_website = ''
    p.save
    assert_equal '', p.organization_website
  end

  should 'save organization_website as typed if has http' do
    p = create_user('person_test').person
    p.organization_website = 'http://website.with.http'
    p.save
    assert_equal 'http://website.with.http', p.organization_website
  end

  should 'not add a friend if already is a friend' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    assert p1.add_friend(p2)
    assert Profile['testuser1'].is_a_friend?(p2)
    refute Profile['testuser1'].add_friend(p2)
  end

  should 'not raise exception when validates person without e-mail' do
    person = create_user('testuser1').person
    person.user.email = nil

    assert_nothing_raised ActiveRecord::RecordInvalid do
      refute person.save
    end
  end

  should 'not be renamed' do
    p = create_user('test_user').person
    assert p.valid?
    assert_raise ArgumentError do
      p.identifier = 'other_person_name'
    end
  end

  should "return none on label if the person hasn't friends" do
    p = fast_create(Person)
    assert_equal 0, p.friends.count
    assert_equal "none", p.more_popular_label
  end

  should "return one friend on label if the profile has one member" do
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p1.add_friend(p2)
    assert_equal 1, p1.friends.count
    assert_equal "one friend", p1.more_popular_label
  end

  should "return the number of friends on label if the person has more than one friend" do
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    p1.add_friend(p2)
    p1.add_friend(p3)
    assert_equal 2, p1.friends.count
    assert_equal "2 friends", p1.more_popular_label

    p4 = fast_create(Person)
    p1.add_friend(p4)
    assert_equal 3, p1.friends.count
    assert_equal "3 friends", p1.more_popular_label
  end

  should 'find more popular people' do
    extend CacheCounterHelper

    Person.delete_all
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)

    update_cache_counter(:friends_count, p1, 1)
    update_cache_counter(:friends_count, p2, 2)
    update_cache_counter(:friends_count, p3, 3)

    assert_order [p3, p2, p1], Person.more_popular
  end

  should 'list people that have no friends in more popular list' do
    person = fast_create(Person)
    assert_includes Person.more_popular, person
  end

  should 'persons has reference to user' do
    person = Person.new
    assert_nothing_raised do
      person.user
    end
  end

  should "see get all sent scraps" do
    p1 = fast_create(Person)
    assert_equal [], p1.scraps_sent
    fast_create(Scrap, :sender_id => p1.id)
    fast_create(Scrap, :sender_id => p1.id)
    assert_equal 2, p1.scraps_sent.count
    p2 = fast_create(Person)
    fast_create(Scrap, :sender_id => p2.id)
    assert_equal 2, p1.scraps_sent.count
    fast_create(Scrap, :sender_id => p1.id)
    assert_equal 3, p1.scraps_sent.count
    fast_create(Scrap, :receiver_id => p1.id)
    assert_equal 3, p1.scraps_sent.count
  end

  should "see get all received scraps" do
    p1 = fast_create(Person)
    assert_equal [], p1.scraps_received
    fast_create(Scrap, :receiver_id => p1.id)
    fast_create(Scrap, :receiver_id => p1.id)
    assert_equal 2, p1.scraps_received.count
    p2 = fast_create(Person)
    fast_create(Scrap, :receiver_id => p2.id)
    assert_equal 2, p1.scraps_received.count
    fast_create(Scrap, :receiver_id => p1.id)
    assert_equal 3, p1.scraps_received.count
    fast_create(Scrap, :sender_id => p1.id)
    assert_equal 3, p1.scraps_received.count
  end

  should "see get all received scraps that are not replies" do
    p1 = fast_create(Person)
    s1 = fast_create(Scrap, :receiver_id => p1.id)
    s2 = fast_create(Scrap, :receiver_id => p1.id)
    s3 = fast_create(Scrap, :receiver_id => p1.id, :scrap_id => s1.id)
    assert_equal 3, p1.scraps_received.count
    assert_equal [s1,s2], p1.scraps_received.not_replies
    p2 = fast_create(Person)
    s4 = fast_create(Scrap, :receiver_id => p2.id)
    s5 = fast_create(Scrap, :receiver_id => p2.id, :scrap_id => s4.id)
    assert_equal 2, p2.scraps_received.count
    assert_equal [s4], p2.scraps_received.not_replies
  end

  should "the followed_by method be protected and true to the person friends and herself by default" do
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    p1.add_friend(p2)
    assert p1.is_a_friend?(p2)
    p1.add_friend(p4)
    assert p1.is_a_friend?(p4)

    assert_equal true, p1.send(:followed_by?,p1)
    assert_equal true, p1.send(:followed_by?,p2)
    assert_equal true, p1.send(:followed_by?,p4)
    assert_equal false, p1.send(:followed_by?,p3)
  end

  should "the person follows her friends and herself by default" do
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    p2.add_friend(p1)
    assert p2.is_a_friend?(p1)
    p4.add_friend(p1)
    assert p4.is_a_friend?(p1)

    assert_equal true, p1.follows?(p1)
    assert_equal true, p1.follows?(p2)
    assert_equal true, p1.follows?(p4)
    assert_equal false, p1.follows?(p3)
  end

  should "a person member of a community follows the community" do
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

    assert_equal true, p1.follows?(c)
    assert_equal true, p3.follows?(c)
    assert_equal false, p2.follows?(c)
  end

  should "the person member of a enterprise follows the enterprise" do
    e = fast_create(Enterprise)
    e.stubs(:closed?).returns(false)
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)

    refute p1.is_member_of?(e)
    e.add_member(p1)
    assert p1.is_member_of?(e)

    refute p3.is_member_of?(e)
    e.add_member(p3)
    assert p3.is_member_of?(e)

    assert_equal true, p1.follows?(e)
    assert_equal true, p3.follows?(e)
    assert_equal false, p2.follows?(e)
  end

  should "the person see all of your scraps" do
    person = fast_create(Person)
    s1 = fast_create(Scrap, :sender_id => person.id)
    assert_equal [s1], person.scraps
    s2 = fast_create(Scrap, :sender_id => person.id)
    assert_equal [s1,s2], person.scraps
    s3 = fast_create(Scrap, :receiver_id => person.id)
    assert_equal [s1,s2,s3], person.scraps
  end

  should "the person browse for a scrap with a Scrap object" do
    person = fast_create(Person)
    s1 = fast_create(Scrap, :sender_id => person.id)
    s2 = fast_create(Scrap, :sender_id => person.id)
    s3 = fast_create(Scrap, :receiver_id => person.id)
    assert_equal s2, person.scraps(s2)
  end

  should "the person browse for a scrap with an integer and string id" do
    person = fast_create(Person)
    s1 = fast_create(Scrap, :sender_id => person.id)
    s2 = fast_create(Scrap, :sender_id => person.id)
    s3 = fast_create(Scrap, :receiver_id => person.id)
    assert_equal s2, person.scraps(s2.id)
    assert_equal s2, person.scraps(s2.id.to_s)
  end

  should "destroy scrap if sender was removed" do
    person = fast_create(Person)
    scrap = fast_create(Scrap, :sender_id => person.id)
    assert_not_nil Scrap.find_by(id: scrap.id)
    person.destroy
    assert_nil Scrap.find_by(id: scrap.id)
  end

  should "the tracked action be notified to person friends and herself" do
    Person.destroy_all
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    p1.add_friend(p2)
    assert p1.is_a_friend?(p2)
    refute p1.is_a_friend?(p3)
    p1.add_friend(p4)
    assert p1.is_a_friend?(p4)

    action_tracker = fast_create(ActionTracker::Record, :user_id => p1.id)
    ActionTrackerNotification.delete_all
    Delayed::Job.destroy_all
    assert_difference 'ActionTrackerNotification.count', 3 do
      Person.notify_activity(action_tracker)
      process_delayed_job_queue
    end
    ActionTrackerNotification.all.map{|a|a.profile}.map do |profile|
      [p1,p2,p4].include?(profile)
    end
  end

  should "the tracked action be notified to friends with delayed job" do
    p1 = Person.first
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    p1.add_friend(p2)
    assert p1.is_a_friend?(p2)
    refute p1.is_a_friend?(p3)
    p1.add_friend(p4)
    assert p1.is_a_friend?(p4)

    action_tracker = fast_create(ActionTracker::Record)

    assert_difference 'Delayed::Job.count', 1 do
      Person.notify_activity(action_tracker)
    end
  end

  should "the tracked action notify friends with one delayed job process" do
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    p1.add_friend(p2)
    assert p1.is_a_friend?(p2)
    refute p1.is_a_friend?(p3)
    p1.add_friend(p4)
    assert p1.is_a_friend?(p4)

    action_tracker = fast_create(ActionTracker::Record, :user_id => p1.id)

    Delayed::Job.delete_all
    assert_difference 'Delayed::Job.count', 1 do
      Person.notify_activity(action_tracker)
    end
    assert_difference 'ActionTrackerNotification.count', 3 do
      process_delayed_job_queue
    end
  end

  should "the community tracked action be notified to the author and to community members" do
    Person.destroy_all
    community = fast_create(Community)
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    community.add_member(p1)
    assert p1.is_member_of?(community)
    community.add_member(p3)
    assert p3.is_member_of?(community)
    refute p2.is_member_of?(community)
    process_delayed_job_queue

    action_tracker = create(ActionTracker::Record, user: p1, verb: 'create_article')
    action_tracker.target = community
    action_tracker.user = p4
    action_tracker.save!
    ActionTrackerNotification.delete_all
    assert_difference 'ActionTrackerNotification.count', 4 do
      Person.notify_activity(action_tracker)
      process_delayed_job_queue
    end
    ActionTrackerNotification.all.map{|a|a.profile}.map do |profile|
      assert [community,p1,p3,p4].include?(profile)
    end
  end

  should "the community tracked action be notified to members with delayed job" do
    p1 = Person.first
    community = fast_create(Community)
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    community.add_member(p1)
    assert p1.is_member_of?(community)
    community.add_member(p3)
    assert p3.is_member_of?(community)
    community.add_member(p4)
    assert p4.is_member_of?(community)
    refute p2.is_member_of?(community)

    action_tracker = fast_create(ActionTracker::Record)
    article = mock()
    action_tracker.stubs(:target).returns(article)
    article.stubs(:is_a?).with(Article).returns(true)
    article.stubs(:is_a?).with(RoleAssignment).returns(false)
    article.stubs(:is_a?).with(Comment).returns(false)
    article.stubs(:profile).returns(community)
    ActionTrackerNotification.delete_all

    assert_difference 'Delayed::Job.count', 1 do
      Person.notify_activity(action_tracker)
    end
    ActionTrackerNotification.all.map{|a|a.profile}.map do |profile|
      assert [community,p1,p3,p4].include?(profile)
    end
  end

  should "remove activities if the person is destroyed" do
    ActionTracker::Record.destroy_all
    ActionTrackerNotification.destroy_all
    person = fast_create(Person)
    a1 = fast_create(ActionTracker::Record, :user_id => person.id )
    a2 = fast_create(ActionTracker::Record, :user_id => person.id )
    a3 = fast_create(ActionTracker::Record)
    assert_equal 3, ActionTracker::Record.count
    fast_create(ActionTrackerNotification, :action_tracker_id => a1.id, :profile_id => person.id)
    fast_create(ActionTrackerNotification, :action_tracker_id => a3.id)
    fast_create(ActionTrackerNotification, :action_tracker_id => a2.id, :profile_id => person.id)
    assert_equal 3, ActionTrackerNotification.count
    person.destroy
    assert_equal 1, ActionTracker::Record.count
    assert_equal 1, ActionTrackerNotification.count
  end

  should "control scrap if is sender or receiver" do
    p1, p2 = fast_create(Person), fast_create(Person)
    s = fast_create(Scrap, :sender_id => p1.id, :receiver_id => p2.id)
    assert p1.can_control_scrap?(s)
    assert p2.can_control_scrap?(s)
  end

  should "not control scrap if is not sender or receiver" do
    p1, p2 = fast_create(Person), fast_create(Person)
    s = fast_create(Scrap, :sender_id => p1.id, :receiver_id => p1.id)
    assert p1.can_control_scrap?(s)
    refute p2.can_control_scrap?(s)
  end

  should "control activity or not" do
    p1, p2 = fast_create(Person), fast_create(Person)
    a = fast_create(ActionTracker::Record, :user_id => p2.id)
    n = fast_create(ActionTrackerNotification, :profile_id => p2.id, :action_tracker_id => a.id)
    refute p1.reload.can_control_activity?(a)
    assert p2.reload.can_control_activity?(a)
  end

  should 'track only one action when a person joins a community' do
    ActionTracker::Record.delete_all
    p = create_user('test_user').person
    c = fast_create(Community, :name => "Foo")
    c.add_member(p)
    assert_equal ["Foo"], ActionTracker::Record.where(verb: 'join_community').last.get_resource_name
    c.reload.add_moderator(p.reload)
    assert_equal ["Foo"], ActionTracker::Record.where(verb: 'join_community').last.get_resource_name
  end

  should 'the tracker target be Community when a person joins a community' do
    ActionTracker::Record.delete_all
    p = create_user('test_user').person
    c = fast_create(Community, :name => "Foo")
    c.add_member(p)
    assert_kind_of Community, ActionTracker::Record.where(verb: 'join_community').last.target
  end

  should 'the community be notified specifically when a person joins a community' do
    ActionTracker::Record.delete_all
    p = create_user('test_user').person
    c = fast_create(Community, :name => "Foo")
    c.add_member(p)
    assert_not_nil ActionTracker::Record.where(verb: 'add_member_in_community').last
  end

  should 'the community specific notification created when a member joins community could not be propagated to members' do
    ActionTracker::Record.delete_all
    p1 = create_user('p1').person
    p2 = create_user('p2').person
    p3 = create_user('p3').person
    c = fast_create(Community, :name => "Foo")
    c.add_member(p1)
    process_delayed_job_queue
    c.add_member(p3)
    process_delayed_job_queue
    assert_equal 4, ActionTracker::Record.count
    assert_equal 5, ActionTrackerNotification.count
    has_add_member_notification = false
    ActionTrackerNotification.all.map do |notification|
      if notification.action_tracker.verb == 'add_member_in_community'
        has_add_member_notification = true
        assert_equal c, notification.profile
      end
    end
    assert has_add_member_notification
  end

  should 'not track when a person leaves a community' do
    p = create_user('test_user').person
    c = fast_create(Community, :name => "Foo")
    c.add_member(p)
    c.add_moderator(p)
    ActionTracker::Record.delete_all
    c.remove_member(p)
    assert_equal [], ActionTracker::Record.all
  end

  should 'get all friends online' do
    now = DateTime.now
    person_1 = create_user('person_1').person
    person_2 = create_user('person_2', :chat_status_at => now, :chat_status => 'chat').person
    person_3 = create_user('person_3', :chat_status_at => now).person
    person_4 = create_user('person_4', :chat_status_at => now, :chat_status => 'dnd').person
    person_1.add_friend(person_2)
    person_1.add_friend(person_3)
    person_1.add_friend(person_4)
    assert_equivalent [person_2, person_3, person_4], person_1.friends
    assert_equivalent [person_2, person_4], person_1.friends.online
  end

  should 'compose bare jabber id by login plus default hostname' do
    person = create_user('online_user').person
    assert_equal "online_user@#{person.environment.default_hostname}", person.jid
  end

  should "compose full jabber id by identifier plus default hostname and short_name as resource" do
    person = create_user('online_user').person
    assert_equal "online_user@#{person.environment.default_hostname}/#{person.short_name}", person.full_jid
  end

  should 'dont get online friends which not updates chat_status in last 15 minutes' do
    now = DateTime.now
    one_hour_ago = DateTime.now - 1.hour
    person = create_user('person_1').person
    friend_1 = create_user('person_2', :chat_status_at => now, :chat_status => 'chat').person
    friend_2 = create_user('person_3', :chat_status_at => one_hour_ago, :chat_status => 'chat').person
    friend_3 = create_user('person_4', :chat_status_at => one_hour_ago, :chat_status => 'dnd').person
    person.add_friend(friend_1)
    person.add_friend(friend_2)
    person.add_friend(friend_3)
    assert_equivalent [friend_1, friend_2, friend_3], person.friends
    assert_equivalent [friend_1], person.friends.online
  end

  should 'return url to a person wall' do
    environment = create_environment('mycolivre.net')
    profile = build(Person, :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)
    assert_equal({ :host => "mycolivre.net", :profile => 'testprofile', :controller => 'profile', :action => 'index', :anchor => 'profile-wall' }, profile.wall_url)
  end

  should 'receive scrap notification' do
    person = fast_create(Person)
    assert person.receives_scrap_notification?
  end

  should 'check if person is the only admin' do
    person = fast_create(Person)
    organization = fast_create(Organization)
    organization.add_admin(person)

    assert person.is_last_admin?(organization)
  end

  should 'check if person is the last admin leaving the community' do
    person = fast_create(Person)
    organization = fast_create(Organization)
    organization.add_admin(person)

    assert person.is_last_admin_leaving?(organization, [])
    refute person.is_last_admin_leaving?(organization, [Role.find_by(key: 'profile_admin')])
  end

  should 'return unique members of a community' do
    person = fast_create(Person)
    community = fast_create(Community)
    community.add_member(person)

    assert_equal [person], Person.members_of(community)
  end

  should 'return unique non-members of a community' do
    member = fast_create(Person)
    person = fast_create(Person)
    community = fast_create(Community)
    community.add_member(member)

    assert_equal (Person.all - Person.members_of(community)).sort, Person.not_members_of(community).sort
  end

  should 'return unique non-friends of a person' do
    friend = fast_create(Person)
    not_friend = fast_create(Person)
    person = fast_create(Person)
    person.add_friend(friend)
    friend.add_friend(person)

    assert_includes Person.not_friends_of(person), not_friend
    assert_not_includes Person.not_friends_of(person), friend
  end

  should 'be able to pass array to members_of' do
    person1 = fast_create(Person)
    community = fast_create(Community)
    community.add_member(person1)
    person2 = fast_create(Person)
    enterprise = fast_create(Enterprise)
    enterprise.add_member(person2)

    assert_includes Person.members_of([community, enterprise]), person1
    assert_includes Person.members_of([community, enterprise]), person2
  end

  should 'be able to pass array to not_members_of' do
    person1 = fast_create(Person)
    community = fast_create(Community)
    community.add_member(person1)
    person2 = fast_create(Person)
    enterprise = fast_create(Enterprise)
    enterprise.add_member(person2)
    person3 = fast_create(Person)

    assert_not_includes Person.not_members_of([community, enterprise]), person1
    assert_not_includes Person.not_members_of([community, enterprise]), person2
    assert_includes Person.not_members_of([community, enterprise]), person3
  end

  should 'find more active people' do
    Person.destroy_all
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)

    ActionTracker::Record.destroy_all
    ActionTracker::Record.create!(:user => p1, :verb => 'leave_scrap')
    ActionTracker::Record.create!(:user => p2, :verb => 'leave_scrap')
    ActionTracker::Record.create!(:user => p2, :verb => 'leave_scrap')
    ActionTracker::Record.create!(:user => p3, :verb => 'leave_scrap')
    ActionTracker::Record.create!(:user => p3, :verb => 'leave_scrap')
    ActionTracker::Record.create!(:user => p3, :verb => 'leave_scrap')

    assert_order [p3,p2,p1] , Person.more_active
  end

  should 'list profiles that have no actions in more active list' do
    profile = fast_create(Person)
    assert_includes Person.more_active, profile
  end

  should 'associate report with the correct complaint' do
    p1 = create_user('user1').person
    p2 = create_user('user2').person
    profile = fast_create(Profile)

    abuse_report1 = build(AbuseReport, :reason => 'some reason')
    assert_difference 'AbuseComplaint.count', 1 do
      p1.register_report(abuse_report1, profile)
    end

    abuse_report2 = build(AbuseReport, :reason => 'some reason')
    assert_no_difference 'AbuseComplaint.count' do
      p2.register_report(abuse_report2, profile)
    end

    abuse_report1.reload
    abuse_report2.reload

    assert_equal abuse_report1.abuse_complaint, abuse_report2.abuse_complaint
    assert_equal abuse_report1.reporter, p1
    assert_equal abuse_report2.reporter, p2
  end

  should 'check if person already reported profile' do
    person = create_user('some-user').person
    profile = fast_create(Profile)
    refute person.already_reported?(profile)

    person.register_report(build(AbuseReport, :reason => 'some reason'), profile)
    person.reload
    assert person.already_reported?(profile)
  end

  should 'disable person' do
    person = create_user('some-user').person
    password = person.user.password
    assert person.visible

    person.disable

    refute person.visible
    assert_not_equal password, person.user.password
  end

  should 'return tracked_actions and scraps as activities' do
    ActionTracker::Record.destroy_all
    person = create_user.person
    another_person = create_user.person

    User.current = another_person.user
    scrap = create(Scrap, defaults_for_scrap(:sender => another_person, :receiver => person, :content => 'A scrap'))
    User.current = person.user
    article = create(TinyMceArticle, :profile => person, :name => 'An article about free software')

    assert_equivalent [scrap,article.activity], person.activities.map { |a| a.activity }
  end

  should 'not return tracked_actions and scraps from others as activities' do
    ActionTracker::Record.destroy_all
    person = create_user.person
    another_person = create_user.person

    person_scrap = create(Scrap, defaults_for_scrap(:sender => person, :receiver => person, :content => 'A scrap from person'))
    another_person_scrap = create(Scrap, defaults_for_scrap(:sender => another_person, :receiver => another_person, :content => 'A scrap from another person'))

    User.current = another_person.user
    create(TinyMceArticle, :profile => another_person, :name => 'An article about free software from another person')
    another_person_activity = ActionTracker::Record.last

    User.current = person.user
    create(TinyMceArticle, :profile => person, :name => 'An article about free software')
    person_activity = ActionTracker::Record.last

    assert_equivalent [person_scrap,person_activity], person.activities.map { |a| a.activity }
  end

  should 'grant every permission over profile for its admin' do
    admin = create_user('some-user').person
    profile = fast_create(Profile)
    profile.add_admin(admin)

    assert admin.has_permission?('anything', profile), 'Admin does not have every permission!'
  end

  should 'grant every permission over profile for environment admin' do
    admin = create_user('some-user').person
    profile = fast_create(Profile)
    environment = profile.environment
    environment.add_admin(admin)

    assert admin.has_permission?('anything', profile), 'Environment admin does not have every permission!'
  end

  should 'allow plugins to extend person\'s permission access' do
    person = create_user('some-user').person
    class Plugin1 < Noosfero::Plugin
      def has_permission?(person, permission, target)
        true
      end
    end

    class Plugin2 < Noosfero::Plugin
      def has_permission?(person, permission, target)
        false
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['PersonTest::Plugin1', 'PersonTest::Plugin2'])

    e = Environment.default
    e.enable_plugin(Plugin1.name)
    e.enable_plugin(Plugin2.name)
    person.stubs('has_permission_without_plugins?').returns(false)

    assert person.has_permission?('bli', Profile.new)
  end

  should 'active fields are private if fields privacy is nil' do
    p = fast_create(Person)
    p.expects(:fields_privacy).returns(nil)
    assert_equal [], p.public_fields
  end

  should 'return public fields' do
    p = fast_create(Person)
    p.stubs(:fields_privacy).returns({ 'sex' => 'public', 'birth_date' => 'private' })
    assert_equal ['sex'], p.public_fields
  end

  should 'define abuser?' do
    abuser = create_user('abuser').person
    create(AbuseComplaint, :reported => abuser).finish
    person = create_user('person').person

    assert abuser.abuser?
    refute person.abuser?
  end

  should 'be able to retrieve abusers and non abusers' do
    abuser1 = create_user('abuser1').person
    create(AbuseComplaint, :reported => abuser1).finish
    abuser2 = create_user('abuser2').person
    create(AbuseComplaint, :reported => abuser2).finish
    person = create_user('person').person

    abusers = Person.abusers

    assert_includes abusers, abuser1
    assert_includes abusers, abuser2
    assert_not_includes abusers, person

    non_abusers = Person.non_abusers

    assert_not_includes non_abusers, abuser1
    assert_not_includes non_abusers, abuser2
    assert_includes non_abusers, person
  end

  should 'not return canceled complaints as abusers' do
    abuser = create_user('abuser1').person
    create(AbuseComplaint, :reported => abuser).finish
    not_abuser = create_user('abuser2').person
    create(AbuseComplaint, :reported => not_abuser).cancel

    abusers = Person.abusers
    assert_includes abusers, abuser
    assert_not_includes abusers, not_abuser

    non_abusers = Person.non_abusers
    assert_not_includes non_abusers, abuser
    assert_includes non_abusers, not_abuser
  end

  should 'admins scope return persons who are admin users' do
    Person.delete_all
    e = Environment.default
    admins = []
    (1..5).each {|i|
      u = create_user('user'+i.to_s)
      e.add_admin(u.person)
      admins << u.person
    }
    (6..10).each {|i|
      u = create_user('user'+i.to_s)
    }
    assert_equivalent admins, Person.admins
  end

  should 'activated scope return persons who are activated users' do
    Person.delete_all
    e = Environment.default
    activated = []
    (1..5).each {|i|
      u = create_user('user'+i.to_s)
      u.activate
      activated << u.person
    }
    (6..10).each {|i|
      u = create_user('user'+i.to_s)
      u.deactivate
    }
    assert_equivalent activated, Person.activated
  end

  should 'deactivated scope return persons who are deactivated users' do
    Person.delete_all
    e = Environment.default
    deactivated = []
    (1..5).each {|i|
      u = create_user('user'+i.to_s)
      u.deactivate
      deactivated << u.person
    }
    (6..10).each {|i|
      u = create_user('user'+i.to_s)
      u.activate
    }
    assert_equivalent deactivated, Person.deactivated
  end

  should 'be able to retrieve memberships by role person has' do
    user = create_user('john').person
    c1 = fast_create(Community, :name => 'a-community')
    c2 = fast_create(Community, :name => 'other-community')
    member_role = Role.create(:name => 'somerandomrole')
    user.affiliate(c2, member_role)

    assert_includes user.memberships_by_role(member_role), c2
    assert_not_includes user.memberships_by_role(member_role), c1
  end

  should 'not list leave_scrap_to_self in activities' do
    person = fast_create(Person)
    at = ActionTracker::Record.create!(:user => person, :verb => 'leave_scrap_to_self')
    person.reload
    assert_equal person.activities, []
  end

  should 'not list add_member_in_community in activities' do
    person = fast_create(Person)
    at = ActionTracker::Record.create!(:user => person, :verb => 'add_member_in_community')
    person.reload
    assert_equal person.activities, []
  end

  should 'not list reply_scrap_on_self in activities' do
    person = fast_create(Person)
    at = ActionTracker::Record.create!(:user => person, :verb => 'reply_scrap_on_self')
    person.reload
    assert_equal person.activities, []
  end

  should 'person notifier be PersonNotifier class' do
    p =  Person.new
    assert p.notifier.kind_of?(PersonNotifier)
  end

  should 'reschedule next notification after update' do
    p = fast_create(Person, :user_id => fast_create(User).id)
    PersonNotifier.any_instance.expects(:reschedule_next_notification_mail).once
    assert p.update_attribute(:name, 'Person name changed')
  end

  should 'merge memberships of plugins to original memberships' do
    class Plugin1 < Noosfero::Plugin
      def person_memberships(person)
        Profile.memberships_of(Person.find_by(identifier: 'person1'))
      end
    end

    class Plugin2 < Noosfero::Plugin
      def person_memberships(person)
        Profile.memberships_of(Person.find_by(identifier: 'person2'))
      end
    end
    Noosfero::Plugin.stubs(:all).returns(['PersonTest::Plugin1', 'PersonTest::Plugin2'])

    Environment.default.enable_plugin(Plugin1)
    Environment.default.enable_plugin(Plugin2)

    original_person = fast_create(Person)
    person1 = fast_create(Person, :identifier => 'person1')
    person2 = fast_create(Person, :identifier => 'person2')
    original_cmm = fast_create(Community)
    plugin1_cmm = fast_create(Community)
    plugin2_cmm = fast_create(Community)
    original_cmm.add_member(original_person)
    plugin1_cmm.add_member(person1)
    plugin2_cmm.add_member(person2)

    assert_includes original_person.memberships, original_cmm
    assert_includes original_person.memberships, plugin1_cmm
    assert_includes original_person.memberships, plugin2_cmm
    assert_equal 3, original_person.memberships.count
  end

  should 'increase friends_count on new friendship' do
    person = create_user('person').person
    friend = create_user('friend').person
    assert_difference 'person.friends_count', 1 do
      assert_difference 'friend.friends_count', 1 do
        person.add_friend(friend)
        friend.reload
      end
      person.reload
    end
  end

  should 'decrease friends_count on friendship removal' do
    person = create_user('person').person
    friend = create_user('friend').person
    person.add_friend(friend)
    friend.reload
    person.reload
    assert_difference 'person.friends_count', -1 do
      assert_difference 'friend.friends_count', -1 do
        person.remove_friend(friend)
        friend.reload
      end
      person.reload
    end
  end

  should 'have a list of suggested people to be friend' do
    person = create_user('person').person
    suggested_friend = fast_create(Person)

    ProfileSuggestion.create(:person => person, :suggestion => suggested_friend)
    assert_equal [suggested_friend], person.suggested_people
  end

  should 'have a list of suggested communities to be member' do
    person = create_user('person').person
    suggested_community = fast_create(Community)

    ProfileSuggestion.create(:person => person, :suggestion => suggested_community)
    assert_equal [suggested_community], person.suggested_communities
  end

  should 'remove profile suggestion when person is destroyed' do
    person = create_user('person').person
    suggested_community = fast_create(Community)

    suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_community)

    person.destroy
    assert_raise ActiveRecord::RecordNotFound do
      ProfileSuggestion.find suggestion.id
    end
  end

  should 'remove profile suggestion when suggested profile is destroyed' do
    person = create_user('person').person
    suggested_community = fast_create(Community)

    suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_community)

    suggested_community.destroy
    assert_raise ActiveRecord::RecordNotFound do
      ProfileSuggestion.find suggestion.id
    end
  end

  should 'not suggest disabled suggestion of people' do
    person = create_user('person').person
    suggested_person = fast_create(Person)
    disabled_suggested_person = fast_create(Person)

    enabled_suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_person)
    disabled_suggestion = ProfileSuggestion.create(:person => person, :suggestion => disabled_suggested_person, :enabled => false)

    assert_equal [suggested_person], person.suggested_people
  end

  should 'not suggest disabled suggestion of communities' do
    person = create_user('person').person
    suggested_community = fast_create(Community)
    disabled_suggested_community = fast_create(Community)

    enabled_suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_community)
    disabled_suggestion = ProfileSuggestion.create(:person => person, :suggestion => disabled_suggested_community, :enabled => false)

    assert_equal [suggested_community], person.suggested_communities
  end

  should 'disable friend suggestion' do
    person = create_user('person').person
    suggested_person = fast_create(Person)

    suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_person)

    assert_difference 'person.suggested_people.count', -1 do
      person.remove_suggestion(suggested_person)
    end
  end

  should 'disable community suggestion' do
    person = create_user('person').person
    suggested_community = fast_create(Community)

    suggestion = ProfileSuggestion.create(:person => person, :suggestion => suggested_community)

    assert_difference 'person.suggested_communities.count', -1 do
      person.remove_suggestion(suggested_community)
    end
  end

  should 'return url to people suggestions for a person' do
    environment = create_environment('mycolivre.net')
    profile = build(Person, :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)
    assert_equal({ :host => "mycolivre.net", :profile => 'testprofile', :controller => 'friends', :action => 'suggest' }, profile.people_suggestions_url)
  end

  should 'return url to communities suggestions for a person' do
    environment = create_environment('mycolivre.net')
    profile = build(Person, :identifier => 'testprofile', :environment_id => create_environment('mycolivre.net').id)
    assert_equal({ :host => "mycolivre.net", :profile => 'testprofile', :controller => 'memberships', :action => 'suggest' }, profile.communities_suggestions_url)
  end

  should 'allow homepage change if user is an environment admin' do
    person = create_user('person').person
    person.environment.expects(:enabled?).with('cant_change_homepage').returns(true)
    person.expects(:is_admin?).returns(true)
    assert person.can_change_homepage?
  end

  should 'allow homepage change if environment feature permit it' do
    person = create_user('person').person
    person.environment.expects(:enabled?).with('cant_change_homepage').returns(false)
    assert person.can_change_homepage?
  end

  should 'follow? return false when no profile is passed as parameter' do
    person = Person.new
    assert_equal false, person.follows?(nil)
  end

  should 'allow posting content when has post_content permission' do
    person = create_user('person').person
    profile = mock
    person.expects(:has_permission?).with('post_content', profile).returns(true)
    assert person.can_post_content?(profile)
  end

  should 'allow posting content when has publish_content permission' do
    person = create_user('person').person
    profile = mock
    person.expects(:has_permission?).with('post_content', profile).returns(false)
    person.expects(:has_permission?).with('publish_content', profile).returns(true)
    assert person.can_post_content?(profile)
  end

  should 'allow posting content when has permission in the parent' do
    person = create_user('person').person
    profile = mock
    parent = mock
    parent.expects(:allow_create?).with(person).returns(true)
    assert person.can_post_content?(profile, parent)
  end

  should 'fetch people there are visible for a user' do
    person = create_user('some-person').person
    admin = create_user('some-admin').person
    Environment.default.add_admin(admin)

    p1 = fast_create(Person, :public_profile => true , :visible => true )
    p1.add_friend(person)
    p2 = fast_create(Person, :public_profile => true , :visible => true )
    p3 = fast_create(Person, :public_profile => false, :visible => true )
    p4 = fast_create(Person, :public_profile => false, :visible => true)
    p4.add_friend(person)
    person.add_friend(p4)
    p5 = fast_create(Person, :public_profile => true , :visible => false)
    p6 = fast_create(Person, :public_profile => false, :visible => false)

    people = Person.visible_for_person(person)
    people_for_admin = Person.visible_for_person(admin)

    assert_includes     people, p1
    assert_includes     people_for_admin, p1

    assert_includes     people, p2
    assert_includes     people_for_admin, p2

    assert_not_includes people, p3
    assert_includes     people_for_admin, p3

    assert_includes     people, p4
    assert_includes     people_for_admin, p4

    assert_not_includes people, p5
    assert_includes     people_for_admin, p5

    assert_not_includes people, p6
    assert_includes     people_for_admin, p6
  end

  should 'vote in a comment with value greater than 1' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    person.vote(comment, 5)
    assert_equal 1, person.vote_count
    assert_equal 5, person.votes.first.vote
    assert person.voted_on?(comment)
  end

  should 'vote in a comment with value lesser than -1' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    person.vote(comment, -5)
    assert_equal 1, person.vote_count
    assert_equal -5, person.votes.first.vote
  end

  should 'vote for a comment' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    refute person.voted_for?(comment)
    person.vote_for(comment)
    assert person.voted_for?(comment)
    refute person.voted_against?(comment)
  end

  should 'vote against a comment' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    refute person.voted_against?(comment)
    person.vote_against(comment)
    refute person.voted_for?(comment)
    assert person.voted_against?(comment)
  end

  should 'do not vote against a comment twice' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    assert person.vote_against(comment)
    refute person.vote_against(comment)
  end

  should 'do not vote for a comment twice' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    assert person.vote_for(comment)
    refute person.vote_for(comment)
  end

  should 'not vote against a voted for comment' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    person.vote_for(comment)
    person.vote_against(comment)
    assert person.voted_for?(comment)
    refute person.voted_against?(comment)
  end

  should 'not vote for a voted against comment' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    person.vote_against(comment)
    person.vote_for(comment)
    refute person.voted_for?(comment)
    assert person.voted_against?(comment)
  end

  should 'undo a vote for a comment' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    person.vote_for(comment)
    assert person.voted_for?(comment)
    person.votes.for_voteable(comment).destroy_all
    refute person.voted_for?(comment)
  end

  should 'count comments voted' do
    comment = fast_create(Comment)
    person = fast_create(Person)

    comment2 = fast_create(Comment)
    comment3 = fast_create(Comment)
    person.vote_for(comment)
    person.vote_for(comment2)
    person.vote_against(comment3)
    assert_equal 3, person.vote_count
    assert_equal 2, person.vote_count(true)
    assert_equal 1, person.vote_count(false)
  end

  should 'vote in a article with value greater than 1' do
    article = fast_create(Article)
    person = fast_create(Person)

    person.vote(article, 5)
    assert_equal 1, person.vote_count
    assert_equal 5, person.votes.first.vote
    assert person.voted_on?(article)
  end

  should 'vote for a article' do
    article = fast_create(Article)
    person = fast_create(Person)

    refute person.voted_for?(article)
    person.vote_for(article)
    assert person.voted_for?(article)
    refute person.voted_against?(article)
  end

  should 'vote against a article' do
    article = fast_create(Article)
    person = fast_create(Person)

    refute person.voted_against?(article)
    person.vote_against(article)
    refute person.voted_for?(article)
    assert person.voted_against?(article)
  end

  should 'access comments through profile' do
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    article = fast_create(Article)
    c1 = fast_create(Comment, :source_id => article.id, :author_id => p1.id)
    c2 = fast_create(Comment, :source_id => article.id, :author_id => p2.id)
    c3 = fast_create(Comment, :source_id => article.id, :author_id => p1.id)

    assert_equivalent [c1,c3], p1.comments
  end

  should 'get people of one community by moderator role' do
    community = fast_create(Community)
    p1 = fast_create(Person)
    p2 = fast_create(Person)

    community.add_member p1
    community.add_moderator p2

    assert_equivalent [p2], Person.with_role(Profile::Roles.moderator(community.environment.id).id)
  end

  should 'get people of one community by admin role' do
    community = fast_create(Community)
    p1 = fast_create(Person)
    p2 = fast_create(Person)

    community.add_admin p1
    community.add_member p2

    assert_equivalent [p1], Person.with_role(Profile::Roles.admin(community.environment.id).id)
  end

  should 'get people with admin role of any community' do
    c1 = fast_create(Community)
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    c1.add_admin p1
    c1.add_member p2

    c2 = fast_create(Community)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    c2.add_admin p4
    c2.add_member p3

    assert_equivalent [p1, p4], Person.with_role(Profile::Roles.admin(c1.environment.id).id)
  end

  should 'get distinct people with moderator role of any community' do
    c1 = fast_create(Community)
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    c1.add_member p1
    c1.add_moderator p2

    c2 = fast_create(Community)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    c2.add_member p4
    c2.add_moderator p3
    c2.add_moderator p2

    assert_equivalent [p2, p3], Person.with_role(Profile::Roles.moderator(c1.environment.id).id)
  end

  should 'count members of a community collected by moderator' do
    c1 = fast_create(Community)
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    c1.add_member p1
    c1.add_moderator p2
    c1.add_member p3

    assert_equal 1, c1.members.with_role(Profile::Roles.moderator(c1.environment.id).id).count
  end

  should 'count people of any community collected by moderator' do
    c1 = fast_create(Community)
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    c1.add_member p1
    c1.add_moderator p2

    c2 = fast_create(Community)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    c2.add_member p4
    c2.add_moderator p3
    c2.add_moderator p2

    assert_equal 2, Person.with_role(Profile::Roles.moderator(c1.environment.id).id).count
  end

  should 'check if a person is added like a member of a community today' do
    person = create_user('person').person
    community = fast_create(Community)

    community.add_member person

    assert !person.member_relation_of(community).empty?, "Person '#{person.identifier}' is not a member of Community '#{community.identifier}'"
    assert_equal Date.current, person.member_since_date(community), "Person '#{person.identifier}' is not added like a member of Community '#{community.identifier}' today"
  end

  should 'a person follows many articles' do
    person = create_user('article_follower').person

    1.upto(10).map do |n|
      person.following_articles <<  fast_create(Article, :profile_id => fast_create(Person))
    end
    assert_equal 10, person.following_articles.count
  end

  should 'not save user after an update on person and user is not touched' do
    user = create_user('testuser')
    person = user.person
    person.user.expects(:save!).never
    person.save!
  end

end
