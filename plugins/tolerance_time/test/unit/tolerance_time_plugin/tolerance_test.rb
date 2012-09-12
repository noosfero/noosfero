require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class ToleranceTimePlugin::ToleranceTest < ActiveSupport::TestCase
  should 'validate presence of profile' do
    tolerance = ToleranceTimePlugin::Tolerance.new
    tolerance.valid?
    assert tolerance.errors.invalid?(:profile_id)

    tolerance.profile = fast_create(Profile)
    tolerance.valid?
    assert !tolerance.errors.invalid?(:profile_id)
  end

  should 'validate uniqueness of profile' do
    profile = fast_create(Profile)
    t1 = ToleranceTimePlugin::Tolerance.create!(:profile => profile)
    t2 = ToleranceTimePlugin::Tolerance.new(:profile => profile)
    t2.valid?

    assert t2.errors.invalid?(:profile_id)
  end

  should 'validate integer format for comment and content tolerance' do
    tolerance = ToleranceTimePlugin::Tolerance.new(:profile => fast_create(Profile))
    assert tolerance.valid?

    tolerance.comment_tolerance = 'sdfa'
    tolerance.content_tolerance = 4.5
    tolerance.valid?
    assert tolerance.errors.invalid?(:comment_tolerance)
    assert tolerance.errors.invalid?(:content_tolerance)

    tolerance.comment_tolerance = 3
    tolerance.content_tolerance = 6
    assert tolerance.valid?
  end
end
