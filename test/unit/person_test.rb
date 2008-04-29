require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < Test::Unit::TestCase
  fixtures :profiles, :users, :environments

  def test_person_must_come_form_the_cration_of_an_user
    p = Person.new(:name => 'John', :identifier => 'john')
    assert !p.valid?
    p.user =  User.create(:login => 'john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe')
    assert !p.valid?
    p = User.create(:login => 'johnz', :email => 'johnz@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    assert p.valid?
  end

  def test_can_associate_to_a_profile
    pr = Profile.new(:identifier => 'mytestprofile', :name => 'My test profile')
    pr.save!
    pe = User.create(:login => 'person', :email => 'person@test.net', :password => 'dhoe', :password_confirmation => 'dhoe').person
    pe.save!
    member_role = Role.create(:name => 'somerandomrole')
    pr.affiliate(pe, member_role)

    assert pe.memberships.include?(pr)
  end

  def test_can_belong_to_an_enterprise
    e = Enterprise.new(:identifier => 'enterprise', :name => 'enterprise')
    e.save!
    p = User.create(:login => 'person', :email => 'person@test.net', :password => 'dhoe', :password_confirmation => 'dhoe').person
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
  
  def test_can_have_user
    u = User.new(:login => 'john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe')
    p = Person.new(:name => 'John', :identifier => 'john')
    u.person = p
    assert u.save
    assert_kind_of User, p.user
    assert_equal 'John', u.person.name
  end

  def test_only_one_person_per_user
    u = User.new(:login => 'john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe')
    assert u.save

    p1 = u.person
    assert_equal u, p1.user
    
    p2 = Person.new
    p2.user = u
    assert !p2.valid?
    assert p2.errors.invalid?(:user_id)
  end

  should "have person info" do
    p = Person.new
    assert_kind_of PersonInfo, p.person_info
  end

  should 'return person_info as info' do
    p = Person.new
    assert_equal p.person_info, p.info
  end

  should 'change the roles of the user' do
    p = User.create(:login => 'jonh', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    e = Enterprise.create(:identifier => 'enter', :name => 'Enter')
    r1 = Role.create(:name => 'associate')
    assert e.affiliate(p, r1)
    r2 = Role.create(:name => 'partner')
    assert p.define_roles([r2], e)
    p.reload
    assert p.role_assignments.any? {|ra| ra.role == r2}
    assert !p.role_assignments.any? {|ra| ra.role == r1}
  end

  should 'report that the user has the permission' do
    p = User.create(:login => 'jonh', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    r = Role.create(:name => 'associate', :permissions => ['edit_profile'])
    e = Enterprise.create(:identifier => 'enterpri', :name => 'Enterpri')
    assert e.affiliate(p, r)
    assert p.reload
    assert e.reload
    assert p.has_permission?('edit_profile', e)
    assert !p.has_permission?('destroy_profile', e)
  end

  should 'get an email address from the associated user instance' do
    p = User.create!(:login => 'jonh', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    assert_equal 'john@doe.org', p.email
  end

  should 'get no email address when there is no associated user' do
    p = Person.new
    assert_nil p.email
  end

  should 'be an admin if have permission of environment administration' do
    role = Role.create!(:name => 'just_another_admin_role')
    env = Environment.create!(:name => 'blah')
    person = create_user('just_another_person').person
    env.affiliate(person, role)
    assert ! person.is_admin?
    role.update_attributes(:permissions => ['view_environment_admin_panel'])
    person.reload
    assert person.is_admin?
  end

  should 'get a default home page and a RSS feed' do
    person = create_user('mytestuser').person

    assert_kind_of Article, person.home_page
    assert_kind_of RssFeed, person.articles.find_by_path('feed')
  end

  should 'create default set of blocks' do
    p = create_user('testingblocks').person

    assert p.boxes[0].blocks.map(&:class).include?(MainBlock), 'person must have a MainBlock upon creation'

    assert p.boxes[1].blocks.map(&:class).include?(ProfileInfoBlock), 'person must have a ProfileInfoBlock upon creation'
    assert p.boxes[1].blocks.map(&:class).include?(RecentDocumentsBlock), 'person must have a RecentDocumentsBlock upon creation'

    assert p.boxes[2].blocks.map(&:class).include?(TagsBlock), 'person must have a Tags Block upon creation'
    assert p.boxes[2].blocks.map(&:class).include?(CommunitiesBlock), 'person must have a CommunitiesBlock upon creation'
    assert p.boxes[2].blocks.map(&:class).include?(EnterprisesBlock), 'person must have a EnterprisesBlock upon creation'
    # TODO check also for a "friends" block

    assert_equal 6,  p.blocks.size
  end

  should 'have friends' do
    p1 = create_user('testuser1').person
    p2 = create_user('testuser2').person
    
    p1.add_friend(p2)

    assert_equal [p2], p1.friends

    p3 = create_user('testuser3').person
    p1.add_friend(p3)

    assert_equal [p2,p3], p1.friends(true) # force reload

  end

  should 'suggest default friend groups list' do
    p = Person.new
    assert_equivalent [ 'friends', 'work', 'school', 'family' ], p.suggested_friend_groups
  end

  should 'suggest current groups as well' do
    p = Person.new
    p.expects(:friend_groups).returns(['group1', 'group2'])
    assert_equivalent [ 'friends', 'work', 'school', 'family', 'group1', 'group2' ], p.suggested_friend_groups
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

  should 'return info name instead of name when info is setted' do
    p = create_user('ze_maria').person
    p.person_info = PersonInfo.create!(:name => 'José')

    assert_equal 'José', p.name
  end

  should 'fallback to login when person_info is not present' do
    p = create_user('randomhacker').person
    p.person_info = nil
    assert_equal 'randomhacker', p.name
  end

end
