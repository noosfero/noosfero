require_relative "../test_helper"

class OrganizationTest < ActiveSupport::TestCase
  fixtures :profiles

  def create_create_enterprise(org)
    region = fast_create(Region, :name => 'some region')
    region.validators << org

    requestor = create_user('testreq').person

    data = {
      :name => 'My new enterprise',
      :identifier => 'mynewenterprise',
      :address => 'satan street, 666',
      :contact_phone => '1298372198',
      :contact_person => 'random joe',
      :legal_form => 'cooperative',
      :economic_activity => 'free software',
      :region_id => region.id,
      :requestor => requestor,
      :target => org,
    }
    create(CreateEnterprise, data)
  end


  should 'not reference organization info' do
    org = Organization.new
    assert_raise NoMethodError do
      org.organization_info
    end
  end

  should 'reference region' do
    org = Organization.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      org.region = 1
    end
    assert_nothing_raised do
      org.region = Region.new
    end
  end

  should 'reference validation info' do
    org = Organization.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      org.validation_info = 1
    end
    assert_nothing_raised do
      org.validation_info = ValidationInfo.new
    end
  end

  should 'provide validation methodology' do
    org = Organization.new
    assert_nil org.validation_methodology

    info = ValidationInfo.new
    info.expects(:validation_methodology).returns('something')
    org.validation_info = info
    assert_equal 'something', org.validation_methodology
  end

  should 'provide validation restrictions' do
    org = Organization.new
    assert_nil org.validation_restrictions

    info = ValidationInfo.new
    info.expects(:restrictions).returns('something')
    org.validation_info = info
    assert_equal 'something', org.validation_restrictions
  end

  should 'have contact_email' do
    org = Organization.new
    assert_respond_to org, :contact_email
  end

  should 'validate contact_email if filled' do
    org = Organization.new
    org.valid?
    assert !org.errors[:contact_email.to_s].present?

    org.contact_email = ''
    org.valid?
    assert !org.errors[:contact_email.to_s].present?


    org.contact_email = 'invalid-email'
    org.valid?
    assert org.errors[:contact_email.to_s].present?

    org.contact_email = 'someone@somedomain.com'
    org.valid?
    assert !org.errors[:contact_email.to_s].present?
  end

  should 'list contact_email plus admin emails as "notification emails"' do
    o = build(Organization, :contact_email => 'org@email.com')
    admin1 = mock; admin1.stubs(:email).returns('admin1@email.com')
    admin2 = mock; admin2.stubs(:email).returns('admin2@email.com')
    o.stubs(:admins).returns([admin1, admin2])

    assert_equal ['org@email.com', 'admin1@email.com', 'admin2@email.com'], o.notification_emails
  end

  should 'list only admins if contact_email is nil' do
    o = build(Organization, :contact_email => nil)
    admin1 = mock; admin1.stubs(:email).returns('admin1@email.com')
    admin2 = mock; admin2.stubs(:email).returns('admin2@email.com')
    o.stubs(:admins).returns([admin1, admin2])

    assert_equal ['admin1@email.com', 'admin2@email.com'], o.notification_emails
  end

  should 'list only admins if contact_email is a blank string' do
    o = build(Organization, :contact_email => '')
    admin1 = mock; admin1.stubs(:email).returns('admin1@email.com')
    admin2 = mock; admin2.stubs(:email).returns('admin2@email.com')
    o.stubs(:admins).returns([admin1, admin2])

    assert_equal ['admin1@email.com', 'admin2@email.com'], o.notification_emails
  end

  should 'use the environment contact email if no emails are listed here' do
    o = build(Organization, :contact_email => '', :environment => Environment.default)
    assert_equal [o.environment.contact_email], o.notification_emails
  end

  should 'list pending enterprise validations' do
    org = Organization.new
    assert_kind_of ActiveRecord::Relation, org.pending_validations
  end

  should 'be able to find a pending validation by its code' do
    org = fast_create(Organization)

    validation = create_create_enterprise(org)

    ok('should find pending validation by code') { validation == org.find_pending_validation(validation.code) }
  end

  should 'return nil when finding for an unexisting pending validation' do
    org = Organization.new
    assert_nil org.find_pending_validation('xxxxxxxxxxxxxxxxxxx')
  end

  should 'be able to find already processed validations' do
    org = Organization.new
    assert_kind_of ActiveRecord::Relation, org.processed_validations
  end

  should 'be able to find an already processed validation by its code' do
    org = fast_create(Organization)
    validation = create_create_enterprise(org)
    validation.finish

    ok('should find processed validation by code') { validation == org.find_processed_validation(validation.code) }
  end

  should 'have boxes and blocks upon creation' do
    profile = create(Organization, :name => 'test org', :identifier => 'testorg')

    assert profile.boxes.size > 0
    assert profile.blocks.size > 0
  end

  should 'have members' do
    assert_equal true, Organization.new.has_members?
  end

  should 'update contact_person' do
    org = fast_create(Organization)
    assert_nil org.contact_person
    org.contact_person = 'person'
    assert_not_nil org.contact_person
  end

  should 'numericality year' do
    count = Organization.count

    org = Organization.new
    org.foundation_year = 'xxxx'
    org.valid?
    assert org.errors[:foundation_year.to_s].present?

    org.foundation_year = 20.07
    org.valid?
    assert org.errors[:foundation_year.to_s].present?
    
    org.foundation_year = 2007
    org.valid?
    assert ! org.errors[:foundation_year.to_s].present?
  end

  should 'has closed' do
    org = Organization.new
    assert_respond_to org, :closed
    assert_respond_to org, :closed?
  end

  should 'allow to add new member' do
    o = fast_create(Organization)
    p = create_user('mytestuser').person

    o.add_member(p)

    assert o.members.include?(p), "Organization should add the new member"
  end
  
  should 'allow to remove members' do
    c = fast_create(Organization)
    p = create_user('myothertestuser').person

    c.add_member(p)
    assert_includes c.members, p
    c.remove_member(p)
    c.reload
    assert_not_includes c.members, p
  end

  should 'allow to add new moderator' do
    o = fast_create(Organization)
    p = create_user('myanothertestuser').person

    o.add_moderator(p)

    assert o.members.include?(p), "Organization should add the new moderator"
  end

  should 'moderator has moderate_comments permission' do
    o = fast_create(Organization)
    p = create_user('myanothertestuser').person
    o.add_moderator(p)
    assert p.has_permission?(:moderate_comments, o)
  end

  should 'be able to change identifier' do
    o = fast_create(Organization)
    assert_nothing_raised do
      o.identifier = 'test_org_new_url'
    end
  end

  should 'be closed if organization is not public' do
    organization = fast_create(Organization)
    assert !organization.closed

    organization.public_profile = false
    organization.save!

    assert organization.closed
  end

  should 'escape malformed html tags' do
    organization = Organization.new
    organization.acronym = "<h1 Malformed >> html >< tag"
    organization.contact_person = "<h1 Malformed >,<<<asfdf> html >< tag"
    organization.contact_email = "<h1<malformed@html.com>>"
    organization.description = "<h1 Malformed /h1>>><<> html ><>h1< tag"
    organization.legal_form = "<h1 Malformed /h1>>><<> html ><>h1< tag"
    organization.economic_activity = "<h1 Malformed /h1>>><<> html ><>h1< tag"
    organization.management_information = "<h1 Malformed /h1>>><<> html ><>h1< tag"
    organization.valid?

    assert_no_match /[<>]/, organization.acronym
    assert_no_match /[<>]/, organization.contact_person
    assert_no_match /[<>]/, organization.contact_email
    assert_no_match /[<>]/, organization.legal_form
    assert_no_match /[<>]/, organization.economic_activity
    assert_no_match /[<>]/, organization.management_information
  end

  should "the followed_by? be true only to members" do
    o = fast_create(Organization)
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)

    assert !p1.is_member_of?(o)
    o.add_member(p1)
    assert p1.is_member_of?(o)

    assert !p3.is_member_of?(o)
    o.add_member(p3)
    assert p3.is_member_of?(o)

    assert_equal true, o.send(:followed_by?,p1)
    assert_equal true, o.send(:followed_by?,p3)
    assert_equal false, o.send(:followed_by?,p2)
  end

  should "compose bare jabber id by identifier plus 'conference' and default hostname" do
    org = fast_create(Organization, :identifier => 'online_community')
    assert_equal "online_community@conference.#{org.environment.default_hostname}", org.jid
  end

  should "compose full jabber id by identifier plus 'conference.default_hostname' and short_name as resource" do
    org = fast_create(Organization, :identifier => 'online_community')
    assert_equal "online_community@conference.#{org.environment.default_hostname}/#{org.short_name}", org.full_jid
  end

  should 'find more popular organizations' do
    o1 = fast_create(Organization)
    o2 = fast_create(Organization)

    p1 = fast_create(Person)
    p2 = fast_create(Person)
    o1.add_member(p1)
    assert_order [o1,o2] , Organization.more_popular

    o2.add_member(p1)
    o2.add_member(p2)
    assert_order [o2,o1] , Organization.more_popular
  end

  should 'list organizations that have no members in more popular list' do
    organization = fast_create(Organization)
    assert_includes Organization.more_popular, organization
  end

  should "return no members on label if the organization has no members" do
    organization = fast_create(Organization)
    assert_equal 0, organization.members_count
    assert_equal "no members", organization.more_popular_label
  end

  should "return one member on label if the organization has one member" do
    person = fast_create(Person)
    organization = fast_create(Organization)
    organization.add_member(person)
    organization.reload

    assert_equal "one member", organization.more_popular_label
  end

  should "return the number of members on label if the organization has more than one member" do
    person1 = fast_create(Person)
    person2 = fast_create(Person)
    organization = fast_create(Organization)

    organization.add_member(person1)
    organization.add_member(person2)
    organization.reload
    assert_equal "2 members", organization.more_popular_label

    person3 = fast_create(Person)
    organization.add_member(person3)
    organization.reload
    assert_equal "3 members", organization.more_popular_label
  end

  should 'find more active organizations' do
    person = fast_create(Person)
    p1 = fast_create(Organization)
    p2 = fast_create(Organization)
    p3 = fast_create(Organization)

    ActionTracker::Record.destroy_all
    ActionTracker::Record.create!(:user => person, :target => p1, :verb => 'leave_scrap')
    ActionTracker::Record.create!(:user => person, :target => p2, :verb => 'leave_scrap')
    ActionTracker::Record.create!(:user => person, :target => p2, :verb => 'leave_scrap')
    ActionTracker::Record.create!(:user => person, :target => p3, :verb => 'leave_scrap')
    ActionTracker::Record.create!(:user => person, :target => p3, :verb => 'leave_scrap')
    ActionTracker::Record.create!(:user => person, :target => p3, :verb => 'leave_scrap')

    assert_order [p3,p2,p1] , Organization.more_active
  end

  should 'list profiles that have no actions in more active list' do
    profile = fast_create(Organization)
    assert_includes Organization.more_active, profile
  end

  should 'validates format of cnpj' do
    organization = build(Organization, :cnpj => '239-234.234')
    organization.valid?
    assert organization.errors[:cnpj.to_s].present?

    organization.cnpj = '94.132.024/0001-48'
    organization.valid?
    assert !organization.errors[:cnpj.to_s].present?
  end

  should 'get members by role' do
    community = fast_create(Community)
    role1 = Role.create!(:name => 'role1')
    person1 = fast_create(Person)
    community.affiliate(person1, role1)
    role2 = Role.create!(:name => 'role2')
    person2 = fast_create(Person)
    community.affiliate(person2, role2)

    assert_equal [person1], community.members_by_role([role1])
  end

  should 'get members by more than one role' do
    community = fast_create(Community)
    role1 = Role.create!(:name => 'role1')
    person1 = fast_create(Person)
    community.affiliate(person1, role1)
    role2 = Role.create!(:name => 'role2')
    person2 = fast_create(Person)
    community.affiliate(person2, role2)
    role3 = Role.create!(:name => 'role3')
    person3 = fast_create(Person)
    community.affiliate(person3, role3)

    assert_equivalent [person2, person3], community.members_by_role([role2, role3])
  end

  should 'return members by role in a json format' do
    organization = fast_create(Organization)
    p1 = create_user('person-1').person
    p2 = create_user('person-2').person
    role = Profile::Roles.organization_member_roles(organization.environment.id).last

    organization.affiliate(p1, role)
    organization.affiliate(p2, role)
    json = organization.members_by_role_to_json(role)

    assert_match ({:id => p1.id, :name => p1.name}).to_json, json
    assert_match ({:id => p2.id, :name => p2.name}).to_json, json
  end

  should 'disable organization' do
    organization = fast_create(Organization, :visible => true)
    assert organization.visible

    organization.disable
    assert !organization.visible
  end

  should 'increase members_count on new membership' do
    member = fast_create(Person)
    organization = fast_create(Organization)
    assert_difference 'organization.members_count', 1 do
      organization.add_member(member)
      organization.reload
    end
  end

  should 'decrease members_count on membership removal' do
    member = fast_create(Person)
    organization = fast_create(Organization)
    organization.add_member(member)
    organization.reload
    assert_difference 'organization.members_count', -1 do
      organization.remove_member(member)
      organization.reload
    end
  end

  should 'check if a community admin user is really a community admin' do
    c = fast_create(Organization, :name => 'my test profile', :identifier => 'mytestprofile')
    admin = create_user('adminuser').person
    c.add_admin(admin)
   
    assert c.is_admin?(admin)
  end

  should 'a member user not be a community admin' do
    c = fast_create(Organization, :name => 'my test profile', :identifier => 'mytestprofile')
    admin = create_user('adminuser').person
    c.add_admin(admin)

    member = create_user('memberuser').person
    c.add_member(member)
    assert !c.is_admin?(member)
  end

  should 'a moderator user not be a community admin' do
    c = fast_create(Organization, :name => 'my test profile', :identifier => 'mytestprofile')
    moderator = create_user('moderatoruser').person
    c.add_moderator(moderator)
    assert !c.is_admin?(moderator)
  end

end
