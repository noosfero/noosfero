require File.dirname(__FILE__) + '/../test_helper'

class OrganizationTest < Test::Unit::TestCase
  fixtures :profiles

  def create_create_enterprise(org)
    region = Region.create!(:name => 'some region', :environment => Environment.default)
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


  should 'reference organization info' do
    org = Organization.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      org.organization_info = 1
    end
    assert_nothing_raised do
      org.organization_info = OrganizationInfo.new
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

  should 'override contact_email to get it from organization_info' do
    org = Organization.new
    assert_nil org.contact_email
    org.organization_info = OrganizationInfo.new(:contact_email => 'test@example.com')
    assert_equal 'test@example.com', org.contact_email
  end

  should 'list pending enterprise validations' do
    org = Organization.new
    assert_kind_of Array, org.pending_validations
  end

  should 'be able to find a pending validation by its code' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')

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
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
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

  should 'update organization_info' do
    org = Organization.create!(:name => 'test org', :identifier => 'testorg')
    assert_nil org.info.contact_person
    org.info = {:contact_person => 'new person'}
    assert_not_nil org.info.contact_person
  end

end
