require File.dirname(__FILE__) + '/../test_helper'

class OrganizationTest < Test::Unit::TestCase
  fixtures :profiles

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
    assert_equal '<em>(not informed)</em>', org.validation_methodology

    info = ValidationInfo.new
    info.expects(:validation_methodology).returns('something')
    org.validation_info = info
    assert_equal 'something', org.validation_methodology
  end

  should 'provide validation restrictions' do
    org = Organization.new
    assert_equal '<em>(not informed)</em>', org.validation_restrictions

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
    flunk 'not yet'
  end

end
