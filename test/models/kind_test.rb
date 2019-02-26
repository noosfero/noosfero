# encoding: UTF-8
require_relative "../test_helper"

class KindTest < ActiveSupport::TestCase
  should 'not be moderated by default' do
    refute Kind.new.moderated
  end

  should 'require an environment' do
    kind = Kind.new
    kind.valid?
    assert kind.errors[:environment].present?
  end

  should 'require a name' do
    kind = Kind.new
    kind.valid?
    assert kind.errors[:name].present?
  end

  should 'create a kind' do
    assert_nothing_raised do
      Kind.create!(:name => 'Regular', :type => 'Profile', :environment => Environment.default)
    end
  end

  should 'not have same name with the same type in the same environment' do
    Kind.create!(:name => 'Regular', :type => 'Profile', :environment => Environment.default)
    kind = Kind.new(:name => 'Regular', :type => 'Profile', :environment => Environment.default)
    kind.valid?
    assert kind.errors[:name].present?
  end

  should 'have profiles' do
    kind = fast_create(Kind, :name=> 'Regular', :type => 'Profile', :environment_id => Environment.default.id)
    p1 = fast_create(Profile)
    p2 = fast_create(Profile)
    p3 = fast_create(Profile)
    kind.profiles << p1
    kind.profiles << p2

    assert_equal 2, kind.profiles.size
    assert_includes kind.profiles, p1
    assert_includes kind.profiles, p2
    assert_not_includes kind.profiles, p3
  end

  should 'add a profile' do
    kind = fast_create(Kind, :name=> 'Regular', :type => 'Profile', :environment_id => Environment.default.id)
    profile = fast_create(Profile)
    assert_not_includes kind.profiles, profile

    kind.add_profile(profile)
    assert_includes kind.profiles, profile
  end

  should 'not add a profile twice' do
    kind = fast_create(Kind, :name=> 'Regular', :type => 'Profile', :environment_id => Environment.default.id)
    profile = fast_create(Profile)
    assert_not_includes kind.profiles, profile

    kind.add_profile(profile)
    kind.add_profile(profile)
    assert_includes kind.profiles, profile
    assert_equal 1, kind.profiles.size
  end

  should 'create ApproveKind task on moderated kinds' do
    kind = fast_create(Kind, :name=> 'Regular', :type => 'Profile', :environment_id => Environment.default.id, :moderated => true)
    profile = fast_create(Profile)
    assert_difference 'ApproveKind.count', 1 do
      kind.add_profile(profile)
    end
  end

  should 'not duplicate ApproveKind task' do
    kind = fast_create(Kind, :name=> 'Regular', :type => 'Profile', :environment_id => Environment.default.id, :moderated => true)
    profile = fast_create(Profile)
    assert_difference 'ApproveKind.count', 1 do
      kind.add_profile(profile)
      kind.add_profile(profile)
    end
  end

  should 'remove a profile' do
    kind = fast_create(Kind, :name=> 'Regular', :type => 'Profile', :environment_id => Environment.default.id)
    profile = fast_create(Profile)
    kind.profiles << profile
    assert_includes kind.profiles, profile

    kind.remove_profile(profile)
    assert_not_includes kind.profiles, profile
  end
end
