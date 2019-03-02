require_relative "../test_helper"

class ValidationInfoTest < ActiveSupport::TestCase

  should 'validate the presence of validation methodology description' do
    info = ValidationInfo.new
    info.valid?
    assert info.errors[:validation_methodology].any?
    info.validation_methodology = 'lalala'
    info.valid?
    refute info.errors[:validation_methodology].any?
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
