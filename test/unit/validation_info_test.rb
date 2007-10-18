require File.dirname(__FILE__) + '/../test_helper'

class ValidationInfoTest < Test::Unit::TestCase

  should 'validate the presence of validation methodology description' do
    info = ValidationInfo.new
    info.valid?
    assert info.errors.invalid?(:validation_methodology)
    info.validation_methodology = 'lalala'
    info.valid?
    assert !info.errors.invalid?(:validation_methodology)
  end

  should 'refer to and validate the presence of an organization' do
    info = ValidationInfo.new
    assert_raise ActiveRecord::AssociationTypeMismatch do
      info.organization = 1
    end
    assert_nothing_raised do
      info.organization = Organization.new
    end
  end

end
