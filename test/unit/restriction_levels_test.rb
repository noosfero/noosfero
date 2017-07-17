# encoding: UTF-8
require_relative "../test_helper"

class RestrictionLevelsTest < ActiveSupport::TestCase
  should 'not restrict access to users with permission higher than requirement' do
    requirement = 2
    user = mock
    profile = mock
    RestrictionLevels.stubs(:permission).with(user, profile).returns(3)

    refute RestrictionLevels.is_restricted?(requirement, user, profile)
  end

  should 'not restrict access to users with permission equal to the requirement' do
    requirement = 3
    user = mock
    profile = mock
    RestrictionLevels.stubs(:permission).with(user, profile).returns(3)

    refute RestrictionLevels.is_restricted?(requirement, user, profile)
  end

  should 'restrict access to users with permission lower than the requirement' do
    requirement = 4
    user = mock
    profile = mock
    RestrictionLevels.stubs(:permission).with(user, profile).returns(3)

    assert RestrictionLevels.is_restricted?(requirement, user, profile)
  end
end
