require_relative "../test_helper"

class ValidationInfoTest < ActiveSupport::TestCase

  should 'validate the presence of validation methodology description' do
    info = ValidationInfo.new
    info.valid?
    assert info.errors[:validation_methodology].any?
    info.validation_methodology = 'lalala'
    info.valid?
    assert !info.errors[:validation_methodology].any?
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

  should 'escape malformed html tags' do
    info = ValidationInfo.new
    info.validation_methodology = "<h1 Malformed >> html >< tag"
    info.restrictions = "<h1 Malformed >> html >< tag"
    info.valid?

    assert_no_match /[<>]/, info.validation_methodology
    assert_no_match /[<>]/, info.restrictions
  end

end
