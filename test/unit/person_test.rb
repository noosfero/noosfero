require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < Test::Unit::TestCase
  fixtures :profiles, :users, :environments

  def test_person_must_come_form_the_cration_of_an_user
    p = Person.new(:environment => Environment.default, :name => 'John', :identifier => 'john')
    assert !p.valid?
    p.user =  create_user('john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe')
    assert !p.valid?
    p = create_user('johnz', :email => 'johnz@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    assert p.valid?
  end

  def test_can_associate_to_a_profile
    pr = Profile.new(:identifier => 'mytestprofile', :name => 'My test profile')
    pr.save!
    pe = create_user('person', :email => 'person@test.net', :password => 'dhoe', :password_confirmation => 'dhoe').person
    pe.save!
    member_role = Role.create(:name => 'somerandomrole')
    pr.affiliate(pe, member_role)

    assert pe.memberships.include?(pr)
  end

  def test_can_belong_to_an_enterprise
    e = Enterprise.new(:identifier => 'enterprise', :name => 'enterprise')
    e.save!
    p = create_user('person', :email => 'person@test.net', :password => 'dhoe', :password_confirmation => 'dhoe').person
    p.save!
    member_role = Role.create(:name => 'somerandomrole')
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
    u = User.new(:login => 'john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe')
    u.save!
    assert_equal u, Person['john'].user
  end

  should 'only one person per user' do
    u = create_user('john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe')

    p1 = u.person
    assert_equal u, p1.user
    
    p2 = Person.new(:environment => Environment.default)
    p2.user = u
    assert !p2.valid?
    assert p2.errors.invalid?(:user_id)
  end

  should "have person info fields" do
    p = Person.new(:environment => Environment.default)
    [ :name, :photo, :contact_information, :birth_date, :sex, :address, :city, :state, :country, :zip_code ].each do |i|
      assert_respond_to p, i
    end
  end

  should 'not have person_info class' do
    p = Person.new(:environment => Environment.default)
    assert_raise NoMethodError do
      p.person_info
    end
  end

  should 'change the roles of the user' do
    p = create_user('jonh', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    e = fast_create(Enterprise)
    r1 = Role.create(:name => 'associate')
    assert e.affiliate(p, r1)
    r2 = Role.create(:name => 'partner')
    assert p.define_roles([r2], e)
    p = Person.find(p.id)
    assert p.role_assignments.any? {|ra| ra.role == r2}
    assert !p.role_assignments.any? {|ra| ra.role == r1}
  end

  should 'report that the user has the permission' do
    p = create_user('john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    r = Role.create(:name => 'associate', :permissions => ['edit_profile'])
    e = fast_create(Enterprise)
    assert e.affiliate(p, r)
    p = Person.find(p.id)
    assert e.reload
    assert p.has_permission?('edit_profile', e)
    assert !p.has_permission?('destroy_profile', e)
  end

  should 'get an email address from the associated user instance' do
    p = create_user('jonh', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    assert_equal 'john@doe.org', p.email
  end

  should 'get no email address when there is no associated user' do
    p = Person.new(:environment => Environment.default)
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
    assert other.errors.invalid?(:email)
  end

  should 'be able to use an e-mail already used in other environment' do
    first = create_user('user', :email => 'user@example.com')

    other_env = fast_create(Environment)
    other = create_user('user', :email => 'other@example.com', :environment => other_env).person
    other.email = 'user@example.com'
    other.valid?
    assert !other.errors.invalid?(:email)
  end

  should 'be an admin if have permission of environment administration' do
    role = Role.create!(:name => 'just_another_admin_role')
    env = fast_create(Environment)
    person = create_user('just_another_person').person
    env.affiliate(person, role)
    assert ! person.is_admin?(env)
    role.update_attributes(:permissions => ['view_environment_admin_panel'])
    person = Person.find(person.id)
    assert person.is_admin?(env)
  end

  should 'separate admins of different environments' do
    env1 = fast_create(Environment)
    env2 = fast_create(Environment)

    # role is an admin role
    role = Role.create!(:name => 'just_another_admin_role')
    role.update_attributes(:permissions => ['view_environment_admin_panel'])

    # user is admin of env1, but not of env2
    person = create_user('just_another_person').person
    env1.affiliate(person, role)

    person = Person.find(person.id)
    assert person.is_admin?(env1)
    assert !person.is_admin?(env2)
  end

  should 'get a default home page and a RSS feed' do
    person = create_user_full('mytestuser').person

    assert_kind_of Article, person.home_page
    assert_kind_of RssFeed, person.articles.find_by_path('feed')
  end

  should 'create default set of blocks' do
    p = create_user_full('testingblocks').person

    assert p.boxes[0].blocks.map(&:class).include?(MainBlock), 'person must have a MainBlock upon creation'

    assert p.boxes[1].blocks.map(&:class).include?(ProfileInfoBlock), 'person must have a ProfileInfoBlock upon creation'
    assert p.boxes[1].blocks.map(&:class).include?(RecentDocumentsBlock), 'person must have a RecentDocumentsBlock upon creation'
    assert p.boxes[1].blocks.map(&:class).include?(TagsBlock), 'person must have a Tags Block upon creation'

    assert p.boxes[2].blocks.map(&:class).include?(CommunitiesBlock), 'person must have a CommunitiesBlock upon creation'
    assert p.boxes[2].blocks.map(&:class).include?(EnterprisesBlock), 'person must have a EnterprisesBlock upon creation'
    assert p.boxes[2].blocks.map(&:class).include?(FriendsBlock), 'person must have a FriendsBlock upon creation'

    assert_equal 7,  p.blocks.size
  end

  should 'have friends' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    
    p1.add_friend(p2)

    p1.friends.reload
    assert_equal [p2], p1.friends

    p3 = create_user('testuser3').person
    p1.add_friend(p3)

    assert_equal [p2,p3], p1.friends(true) # force reload

  end

  should 'suggest default friend groups list' do
    p = Person.new(:environment => Environment.default)
    assert_equivalent [ 'friends', 'work', 'school', 'family' ], p.suggested_friend_groups
  end

  should 'suggest current groups as well' do
    p = Person.new(:environment => Environment.default)
    p.expects(:friend_groups).returns(['group1', 'group2'])
    assert_equivalent [ 'friends', 'work', 'school', 'family', 'group1', 'group2' ], p.suggested_friend_groups
  end

  should 'accept nil friend groups when suggesting friend groups' do
    p = Person.new(:environment => Environment.default)
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

    assert_difference Friendship, :count, -1 do
      p1.remove_friend(p2)
    end
    assert_not_includes p1.friends(true), p2
  end

  should 'destroy friendships when person is destroyed' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    p1.add_friend(p2, 'friends')
    p2.add_friend(p1, 'friends')

    assert_difference Friendship, :count, -2 do
      p1.destroy
    end
    assert_not_includes p2.friends(true), p1
  end

  should 'destroy use when person is destroyed' do
    person = create_user('testuser').person
    assert_difference User, :count, -1 do
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
    p = Person.new(:environment => Environment.default)
    assert p.respond_to?(:photo)
    assert p.respond_to?(:address)
    assert p.respond_to?(:contact_information)
  end

  should 'required name' do
    person = Person.new(:environment => Environment.default)
    assert !person.valid?
    assert person.errors.invalid?(:name)
  end

  should 'already request friendship' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    AddFriend.create!(:person => p1, :friend => p2)
    assert p1.already_request_friendship?(p2)
  end

  should 'have e-mail addresses' do
    env = fast_create(Environment)
    env.domains <<  Domain.new(:name => 'somedomain.com')
    person = Person.new(:environment => env, :identifier => 'testuser')
    person.expects(:environment).returns(env)

    assert_equal ['testuser@somedomain.com'], person.email_addresses
  end

  should 'not show www in e-mail addresses when force_www=true' do
    env = fast_create(Environment)
    env.domains <<  Domain.new(:name => 'somedomain.com')
    env.update_attribute(:force_www, true)
    person = Person.new(:environment => env, :identifier => 'testuser')
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
    env = Environment.create!(:name => 'test env')
    p = create_user('test_user', :environment => env).person
    assert_kind_of Person, p.template
  end

  should 'destroy all task that it requested when destroyed' do
    p = create_user('test_profile').person

    assert_no_difference Task, :count do
      Task.create(:requestor => p)
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
    assert !c1.tasks.pending.empty?
    c1.add_admin(p1)

    c2 = fast_create(Community)
    p2 = create_user('user_without_tasks').person
    c2.add_admin(p2)

    assert_includes Person.with_pending_tasks, p1
    assert_not_includes Person.with_pending_tasks, p2
  end

  should 'not allow simple member to view group pending tasks' do
    c = fast_create(Community)
    c.tasks << Task.new
    p = create_user('user_without_tasks').person
    c.add_member(p)

    assert_not_includes Person.with_pending_tasks, p
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
    person = Person.new(:environment => e)

    assert_equal e.active_person_fields, person.active_fields
  end

  should 'return required_person_fields' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['cell_phone', 'comercial_phone']).at_least_once
    person = Person.new(:environment => e)

    assert_equal e.required_person_fields, person.required_fields
  end

  should 'require fields if person needs' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['cell_phone']).at_least_once
    person = Person.new(:environment => e)
    assert ! person.valid?
    assert person.errors.invalid?(:cell_phone)

    person.cell_phone = '99999'
    person.valid?
    assert ! person.errors.invalid?(:cell_phone)
  end

  should 'require custom_area_of_study if area_of_study is others' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['area_of_study', 'custom_area_of_study']).at_least_once
  
    person = Person.new(:environment => e, :area_of_study => 'Others')
    assert !person.valid?
    assert person.errors.invalid?(:custom_area_of_study)

    person.custom_area_of_study = 'Customized area of study'
    person.valid?
    assert ! person.errors.invalid?(:custom_area_of_study)
  end

  should 'not require custom_area_of_study if area_of_study is not others' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['area_of_study']).at_least_once

    person = Person.new(:environment => e, :area_of_study => 'Agrometeorology')
    person.valid?
    assert ! person.errors.invalid?(:custom_area_of_study)
  end

  should 'require custom_formation if formation is others' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['formation', 'custom_formation']).at_least_once

    person = Person.new(:environment => e, :formation => 'Others')
    assert !person.valid?
    assert person.errors.invalid?(:custom_formation)

    person.custom_formation = 'Customized formation'
    person.valid?
    assert ! person.errors.invalid?(:custom_formation)
  end

  should 'not require custom_formation if formation is not others' do
    e = Environment.default
    e.expects(:required_person_fields).returns(['formation']).at_least_once
 
    person = Person.new(:environment => e, :formation => 'Agrometeorology')
    assert !person.valid?
    assert ! person.errors.invalid?(:custom_formation)
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
    assert !p1.is_a_friend?(p2)
  end

  should 'refuse join community' do
    p = create_user('test_user').person
    c = fast_create(Community)

    assert p.ask_to_join?(c)
    p.refuse_join(c)
    assert !p.ask_to_join?(c)
  end

  should 'not ask to join for a member' do
    p = create_user('test_user').person
    c = fast_create(Community)
    c.add_member(p)

    assert !p.ask_to_join?(c)
  end

  should 'not ask to join if already asked' do
    p = create_user('test_user').person
    c = fast_create(Community)
    AddMember.create!(:person => p, :organization => c)

    assert !p.ask_to_join?(c)
  end

  should 'ask to join if community is not public' do
    person = fast_create(Person)
    community = fast_create(Community, :public_profile => false)

    assert person.ask_to_join?(community)
  end

  should 'not ask to join if community is not visible' do
    person = fast_create(Person)
    community = fast_create(Community, :visible => false)

    assert !person.ask_to_join?(community)
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
    assert !Profile['testuser1'].add_friend(p2)
  end

  should 'not raise exception when validates person without e-mail' do
    person = create_user('testuser1').person
    person.user.email = nil

    assert_nothing_raised ActiveRecord::RecordInvalid do
      assert !person.save
    end
  end

  should 'not rename' do
    assert_valid p = create_user('test_user').person
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
    Person.delete_all
    env = fast_create(Environment)
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)

    p1.add_friend(p2)
    assert_equal [p1], Person.more_popular

    p2.add_friend(p1)
    p2.add_friend(p3)
    assert_equal [p2,p1] , Person.more_popular

    p2.remove_friend(p3)
    assert_equal [p1,p2] , Person.more_popular
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

    assert !p1.is_member_of?(c)
    c.add_member(p1)
    assert p1.is_member_of?(c)

    assert !p3.is_member_of?(c)
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

    assert !p1.is_member_of?(e)
    e.add_member(p1)
    assert p1.is_member_of?(e)

    assert !p3.is_member_of?(e)
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

  should "the person browse for a scrap with an inter and string id" do
    person = fast_create(Person)
    s1 = fast_create(Scrap, :sender_id => person.id)
    s2 = fast_create(Scrap, :sender_id => person.id)
    s3 = fast_create(Scrap, :receiver_id => person.id)
    assert_equal s2, person.scraps(s2.id)
    assert_equal s2, person.scraps(s2.id.to_s)
  end

  should "the tracked action be notified to person friends and herself" do
    p1 = Person.first
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    p1.add_friend(p2)
    assert p1.is_a_friend?(p2)
    assert !p1.is_a_friend?(p3)
    p1.add_friend(p4)
    assert p1.is_a_friend?(p4)
    
    action_tracker = fast_create(ActionTracker::Record)
    ActionTrackerNotification.delete_all
    count = ActionTrackerNotification.count
    Delayed::Job.destroy_all
    Person.notify_activity(action_tracker)
    process_delayed_job_queue 
    assert_equal count + 3, ActionTrackerNotification.count
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
    assert !p1.is_a_friend?(p3)
    p1.add_friend(p4)
    assert p1.is_a_friend?(p4)
    
    action_tracker = fast_create(ActionTracker::Record)

    assert_difference(Delayed::Job, :count, 1) do
      Person.notify_activity(action_tracker)
    end
  end

  should "the tracked action notify friends with one delayed job process followed by others jobs created after run the firt job" do
    p1 = Person.first
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    p4 = fast_create(Person)

    p1.add_friend(p2)
    assert p1.is_a_friend?(p2)
    assert !p1.is_a_friend?(p3)
    p1.add_friend(p4)
    assert p1.is_a_friend?(p4)
    
    action_tracker = fast_create(ActionTracker::Record)

    Delayed::Job.delete_all
    assert_difference(Delayed::Job, :count, 1) do
      Person.notify_activity(action_tracker)
    end

    assert_difference(ActionTrackerNotification, :count, 2) do
      process_delayed_job_queue
    end
  end

  should "the community tracked action be notified to the author and to community members" do
    p1 = Person.first
    community = fast_create(Community)
    p2 = fast_create(Person)
    p3 = fast_create(Person)

    community.add_member(p1)
    assert p1.is_member_of?(community)
    community.add_member(p3)
    assert p3.is_member_of?(community)
    assert !p2.is_member_of?(community)
    process_delayed_job_queue
    
    action_tracker = fast_create(ActionTracker::Record)
    article = mock()
    action_tracker.stubs(:dispatcher).returns(article)
    article.stubs(:is_a?).with(Article).returns(true)
    article.stubs(:is_a?).with(RoleAssignment).returns(false)
    article.stubs(:is_a?).with(Comment).returns(false)
    article.stubs(:profile).returns(community)
    ActionTrackerNotification.delete_all
    assert_difference(ActionTrackerNotification, :count, 3) do
      Person.notify_activity(action_tracker)
      process_delayed_job_queue
    end
    ActionTrackerNotification.all.map{|a|a.profile}.map do |profile|
      assert [community,p1,p3].include?(profile)
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
    assert !p2.is_member_of?(community)
      
    action_tracker = fast_create(ActionTracker::Record)
    article = mock()
    action_tracker.stubs(:dispatcher).returns(article)
    article.stubs(:is_a?).with(Article).returns(true)
    article.stubs(:is_a?).with(RoleAssignment).returns(false)
    article.stubs(:is_a?).with(Comment).returns(false)
    article.stubs(:profile).returns(community)
    ActionTrackerNotification.delete_all

    assert_difference(Delayed::Job, :count, 2) do
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
    fast_create(ActionTrackerNotification, :action_tracker_id => a1.id)
    fast_create(ActionTrackerNotification, :action_tracker_id => a1.id)
    fast_create(ActionTrackerNotification, :action_tracker_id => a3.id)
    fast_create(ActionTrackerNotification, :action_tracker_id => a2.id)
    assert_equal 4, ActionTrackerNotification.count
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
    assert !p2.can_control_scrap?(s)
  end

  should "control activity or not" do
    p1, p2 = fast_create(Person), fast_create(Person)
    a = fast_create(ActionTracker::Record, :user_id => p2.id)
    n = fast_create(ActionTrackerNotification, :profile_id => p2.id, :action_tracker_id => a.id)
    assert !p1.reload.can_control_activity?(a)
    assert p2.reload.can_control_activity?(a)
  end

  should 'track only one action when a person joins a community' do
    ActionTracker::Record.delete_all
    p = create_user('test_user').person
    c = fast_create(Community, :name => "Foo")
    c.add_member(p)
    assert_equal ["Foo"], ActionTracker::Record.last.get_resource_name
    c.reload.add_moderator(p.reload)
    assert_equal ["Foo"], ActionTracker::Record.last.get_resource_name
  end

  should 'track only one action when a person leaves a community' do
    p = create_user('test_user').person
    c = fast_create(Community, :name => "Foo")
    c.add_member(p)
    c.add_moderator(p)
    ActionTracker::Record.delete_all
    c.remove_member(p)
    assert_equal ["Foo"], ActionTracker::Record.last.get_resource_name
  end

end
