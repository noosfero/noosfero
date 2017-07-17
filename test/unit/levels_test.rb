# encoding: UTF-8
require_relative "../test_helper"

class LevelsTest < ActiveSupport::TestCase
  should 'return range_options' do
    assert_equal [:visitors, :users, :related, :self, :nobody], AccessLevels.range_options
    assert_equal [:users, :related, :self, :nobody], AccessLevels.range_options(1)
    assert_equal [:users, :related, :self], AccessLevels.range_options(1,3)
    assert_equal [:nobody], AccessLevels.range_options(4)
  end

  should 'return pick_options' do
    assert_equal [:visitors], AccessLevels.pick_options([0])
    assert_equal [:users, :self], AccessLevels.pick_options([1,3])
    assert_equal [:visitors, :related, :self, :nobody], AccessLevels.pick_options([0,2,3,4])
  end

  should 'return base labels' do
    labels = AccessLevels.labels(Profile.new)
    assert_equal 'Visitors', labels[:visitors]
    assert_equal 'Logged users', labels[:users]
    assert_equal 'Friends / Members', labels[:related]
    assert_equal 'Me / Administrators', labels[:self]
    assert_equal 'Nobody', labels[:nobody]
  end

  should 'return person labels' do
    labels = AccessLevels.labels(Person.new)
    assert_equal 'Friends', labels[:related]
    assert_equal 'Me', labels[:self]
  end

  should 'return group labels' do
    labels = AccessLevels.labels(Organization.new)
    assert_equal 'Members', labels[:related]
    assert_equal 'Administrators', labels[:self]
  end

  should 'give environment admin level 3 permission' do
    profile = fast_create(Profile)
    user = create_user('environment-admin').person
    profile.environment.add_admin(user)
    assert_equal 3, Levels.permission(user, profile)
  end

  should 'give profile admin level 3 permission' do
    profile = fast_create(Profile)
    user = create_user('profile-admin').person
    profile.add_admin(user)
    assert_equal 3, Levels.permission(user, profile)
  end

  should 'give own user level 3 permission' do
    user = fast_create(Person)
    assert_equal 3, Levels.permission(user, user)
  end

  should 'give friend level 2 permission' do
    person = fast_create(Person)
    friend = fast_create(Person)
    person.add_friend(friend)
    assert_equal 2, Levels.permission(friend, person)
  end

  should 'give member level 2 permission' do
    group = fast_create(Organization)
    member = fast_create(Person)
    group.add_admin(create_user('admin').person)
    group.add_member(member)
    assert_equal 2, Levels.permission(member, group)
  end

  should 'give logged user level 1 permission' do
    profile = fast_create(Profile)
    user = fast_create(Person)
    assert_equal 1, Levels.permission(user, profile)
  end

  should 'give visitors level 0 permission' do
    profile = fast_create(Profile)
    assert_equal 0, Levels.permission(nil, profile)
  end
end


