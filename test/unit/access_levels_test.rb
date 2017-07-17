# encoding: UTF-8
require_relative "../test_helper"

class AccessLevelsTest < ActiveSupport::TestCase
  should 'allow access to users with permission higher than requirement' do
    requirement = 2
    user = mock
    profile = mock
    AccessLevels.stubs(:permission).with(user, profile).returns(3)

    assert AccessLevels.can_access?(requirement, user, profile)
  end

  should 'allow access to users with permission equal to the requirement' do
    requirement = 3
    user = mock
    profile = mock
    AccessLevels.stubs(:permission).with(user, profile).returns(3)

    assert AccessLevels.can_access?(requirement, user, profile)
  end

  should 'not allow access to users with permission lower than the requirement' do
    requirement = 4
    user = mock
    profile = mock
    AccessLevels.stubs(:permission).with(user, profile).returns(3)

    refute AccessLevels.can_access?(requirement, user, profile)
  end
end
