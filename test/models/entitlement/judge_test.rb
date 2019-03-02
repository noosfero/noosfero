# encoding: UTF-8
require_relative "../../test_helper"

class Entitlement::JudgeTest < ActiveSupport::TestCase
  def setup
    @object = Object.new
    @object.extend(Entitlement::Judge)
    @user = create_user('user').person
  end

  attr_reader :object, :user

  should 'order checks based on higher level' do
    check1 = mock
    class1 = mock
    check1.stubs(:class).returns(class1)
    class1.stubs(:level).returns(5)

    check2 = mock
    class2 = mock
    check2.stubs(:class).returns(class2)
    class2.stubs(:level).returns(10)

    check3 = mock
    class3 = mock
    check3.stubs(:class).returns(class3)
    class3.stubs(:level).returns(15)

    checks = [check2, check1, check3]
    object.stubs(:checks).returns(checks)

    assert_equivalent object.ordered_checks, [check3, check2, check1]
  end

  should 'returns higher entitled access level check' do
    check1 = mock
    class1 = mock
    check1.stubs(:class).returns(class1)
    class1.stubs(:level).returns(5)
    check1.expects(:entitles?).with(user).returns(true).never

    check2 = mock
    class2 = mock
    check2.stubs(:class).returns(class2)
    class2.stubs(:level).returns(10)
    check2.expects(:entitles?).with(user).returns(true).once


    check3 = mock
    class3 = mock
    check3.stubs(:class).returns(class3)
    class3.stubs(:level).returns(15)
    check3.expects(:entitles?).with(user).returns(false).once

    checks = [check2, check1, check3]
    object.stubs(:checks).returns(checks)

    assert_equal 10, object.entitlement(user)
  end

  should 'display to user with enough access level' do
    object.stubs('access_requirement').returns(10)

    object.stubs('entitlement').with(user).returns(15)
    assert object.entitles?(user)

    object.stubs('entitlement').with(user).returns(10)
    assert object.entitles?(user)

    object.stubs('entitlement').with(user).returns(5)
    refute object.entitles?(user)
  end

  should 'accept custom requirement for display to' do
    object.stubs('access_requirement').returns(15)
    object.stubs('custom_requirement').returns(10)

    object.stubs('entitlement').with(user).returns(15)
    assert object.entitles?(user, :custom)

    object.stubs('entitlement').with(user).returns(10)
    assert object.entitles?(user, :custom)

    object.stubs('entitlement').with(user).returns(5)
    refute object.entitles?(user, :custom)
  end

  should 'restrict to user without enough access level' do
    object.stubs('access_requirement').returns(10)

    object.stubs('entitlement').with(user).returns(5)
    assert object.demands?(user)

    object.stubs('entitlement').with(user).returns(10)
    assert object.demands?(user)

    object.stubs('entitlement').with(user).returns(15)
    refute object.demands?(user)
  end

  should 'accept custom requirement for restrict to' do
    object.stubs('access_requirement').returns(15)
    object.stubs('custom_requirement').returns(10)

    object.stubs('entitlement').with(user).returns(15)
    refute object.demands?(user, :custom)

    object.stubs('entitlement').with(user).returns(10)
    assert object.demands?(user, :custom)

    object.stubs('entitlement').with(user).returns(5)
    assert object.demands?(user, :custom)
  end
end
