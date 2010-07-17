require File.dirname(__FILE__) + '/../test_helper'

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
    CreateEnterprise.create!(data)
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
    assert !org.errors.invalid?(:contact_email)

    org.contact_email = ''
    org.valid?
    assert !org.errors.invalid?(:contact_email)


    org.contact_email = 'invalid-email'
    org.valid?
    assert org.errors.invalid?(:contact_email)

    org.contact_email = 'someone@somedomain.com'
    org.valid?
    assert !org.errors.invalid?(:contact_email)
  end

  should 'list contact_email plus admin emails as "notification emails"' do
    o = Organization.new(:contact_email => 'org@email.com')
    admin1 = mock; admin1.stubs(:email).returns('admin1@email.com')
    admin2 = mock; admin2.stubs(:email).returns('admin2@email.com')
    o.stubs(:admins).returns([admin1, admin2])

    assert_equal ['org@email.com', 'admin1@email.com', 'admin2@email.com'], o.notification_emails
  end

  should 'list only admins if contact_email is nil' do
    o = Organization.new(:contact_email => nil)
    admin1 = mock; admin1.stubs(:email).returns('admin1@email.com')
    admin2 = mock; admin2.stubs(:email).returns('admin2@email.com')
    o.stubs(:admins).returns([admin1, admin2])

    assert_equal ['admin1@email.com', 'admin2@email.com'], o.notification_emails
  end

  should 'list only admins if contact_email is a blank string' do
    o = Organization.new(:contact_email => '')
    admin1 = mock; admin1.stubs(:email).returns('admin1@email.com')
    admin2 = mock; admin2.stubs(:email).returns('admin2@email.com')
    o.stubs(:admins).returns([admin1, admin2])

    assert_equal ['admin1@email.com', 'admin2@email.com'], o.notification_emails
  end


  should 'list pending enterprise validations' do
    org = Organization.new
    assert_kind_of Array, org.pending_validations
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
    assert_kind_of Array, org.processed_validations
  end

  should 'be able to find an already processed validation by its code' do
    org = fast_create(Organization)
    validation = create_create_enterprise(org)
    validation.finish

    ok('should find processed validation by code') { validation == org.find_processed_validation(validation.code) }
  end

  should 'have boxes and blocks upon creation' do
    profile = Organization.create!(:name => 'test org', :identifier => 'testorg')

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
    assert org.errors.invalid?(:foundation_year)

    org.foundation_year = 20.07
    org.valid?
    assert org.errors.invalid?(:foundation_year)
    
    org.foundation_year = 2007
    org.valid?
    assert ! org.errors.invalid?(:foundation_year)
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

end
