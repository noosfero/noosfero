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
    assert p.enterprise_memberships.include?(e)
  end

  should 'belong to communities' do
    c = Community.create!(:name => 'my test community')
    p = create_user('mytestuser').person

    c.add_member(p)

    assert p.community_memberships.include?(c), "Community should add a new member"
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
    e = Enterprise.create(:identifier => 'enter', :name => 'Enter')
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
    e = Enterprise.create(:identifier => 'enterpri', :name => 'Enterpri')
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
    first = create_user('firstuser', :email => 'user@domain.com')
    second = create_user('seconduser', :email => 'other@domain.com')
    second.email = 'user@domain.com'
    second.valid?
    assert second.errors.invalid?(:email)
  end

  should 'be an admin if have permission of environment administration' do
    role = Role.create!(:name => 'just_another_admin_role')
    env = Environment.create!(:name => 'blah')
    person = create_user('just_another_person').person
    env.affiliate(person, role)
    assert ! person.is_admin?(env)
    role.update_attributes(:permissions => ['view_environment_admin_panel'])
    person = Person.find(person.id)
    assert person.is_admin?(env)
  end

  should 'separate admins of different environments' do
    env1 = Environment.create!(:name => 'blah1')
    env2 = Environment.create!(:name => 'blah2')

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

  should 'return info name instead of name when info is setted' do
    p = create_user('ze_maria').person
    assert_equal 'ze_maria', p.name
    p.name = 'José'
    assert_equal 'José', p.name
  end

  should 'have favorite enterprises' do
    p = create_user('test_person').person
    e = Enterprise.create!(:name => 'test_ent', :identifier => 'test_ent')

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
    env = Environment.create!(:name => 'sample env', :domains => [Domain.new(:name => 'somedomain.com')])
    person = Person.new(:environment => env, :identifier => 'testuser')
    person.expects(:environment).returns(env)

    assert_equal ['testuser@somedomain.com'], person.email_addresses
  end

  should 'not show www in e-mail addresses when force_www=true' do
    env = Environment.create!(:name => 'sample env', :domains => [Domain.new(:name => 'somedomain.com')])
    env.force_www = true
    env.save
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
    c1 = Community.create!(:name => 'my test community')
    c1.tasks << Task.new
    assert !c1.tasks.pending.empty?
    c1.add_admin(p1)

    c2 = Community.create!(:name => 'my other test community')
    p2 = create_user('user_without_tasks').person
    c2.add_admin(p2)

    assert_includes Person.with_pending_tasks, p1
    assert_not_includes Person.with_pending_tasks, p2
  end

  should 'not allow simple member to view group pending tasks' do
    c = Community.create!(:name => 'my test community')
    c.tasks << Task.new
    p = create_user('user_without_tasks').person
    c.add_member(p)

    assert_not_includes Person.with_pending_tasks, p
  end

  should 'person has organization pending tasks' do
    c = Community.create!(:name => 'my test community')
    c.tasks << Task.new
    p = create_user('user_with_tasks').person
    c.add_admin(p)

    assert p.has_organization_pending_tasks?
  end

  should 'select organization pending tasks' do
    c = Community.create!(:name => 'my test community')
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
    c = Community.create!(:name => 'Test community', :identifier => 'test_community')

    assert p.ask_to_join?(c)
    p.refuse_join(c)
    assert !p.ask_to_join?(c)
  end

  should 'not ask to join for a member' do
    p = create_user('test_user').person
    c = Community.create!(:name => 'Test community', :identifier => 'test_community')
    c.add_member(p)

    assert !p.ask_to_join?(c)
  end

  should 'not ask to join if already asked' do
    p = create_user('test_user').person
    c = Community.create!(:name => 'Test community', :identifier => 'test_community')
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

end
