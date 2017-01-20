# encoding: UTF-8
require_relative "../test_helper"

class AccessLevelsTest < ActiveSupport::TestCase
  should 'return options range' do
    assert_equal [:visitors, :users, :related, :self], AccessLevels.options
    assert_equal [:users, :related, :self], AccessLevels.options(1)
    assert_equal [:related, :self], AccessLevels.options(2)
    assert_equal [:self], AccessLevels.options(3)
  end

  should 'return base labels' do
    labels = AccessLevels.labels(Profile.new)
    assert_equal 'Visitors', labels[:visitors]
    assert_equal 'Logged users', labels[:users]
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

  should 'allow environment admin to access every permission' do
    profile = fast_create(Profile)
    user = create_user('environment-admin').person
    profile.environment.add_admin(user)
    AccessLevels.options.each do |option|
      assert AccessLevels.can_access?(option, user, profile)
    end
  end

  should 'allow profile admin to access every permission' do
    profile = fast_create(Profile)
    user = create_user('profile-admin').person
    profile.add_admin(user)
    AccessLevels.options.each do |option|
      assert AccessLevels.can_access?(option, user, profile)
    end
  end

  should 'allow own user access every permission' do
    user = fast_create(Person)
    AccessLevels.options.each do |option|
      assert AccessLevels.can_access?(option, user, user)
    end
  end

  should 'allow friend to access only lower permissions than related' do
    person = fast_create(Person)
    friend = fast_create(Person)
    person.add_friend(friend)
    refute AccessLevels.can_access?(AccessLevels::LEVELS[:self], friend, person)
    assert AccessLevels.can_access?(AccessLevels::LEVELS[:related], friend, person)
    assert AccessLevels.can_access?(AccessLevels::LEVELS[:users], friend, person)
    assert AccessLevels.can_access?(AccessLevels::LEVELS[:visitors], friend, person)
  end

  should 'allow member to access only lower permissions than related' do
    group = fast_create(Organization)
    member = fast_create(Person)
    group.add_admin(create_user('admin').person)
    group.add_member(member)
    refute AccessLevels.can_access?(AccessLevels::LEVELS[:self], member, group)
    assert AccessLevels.can_access?(AccessLevels::LEVELS[:related], member, group)
    assert AccessLevels.can_access?(AccessLevels::LEVELS[:users], member, group)
    assert AccessLevels.can_access?(AccessLevels::LEVELS[:visitors], member, group)
  end

  should 'allow logged user to access only lower permissions than users' do
    profile = fast_create(Profile)
    user = fast_create(Person)
    refute AccessLevels.can_access?(AccessLevels::LEVELS[:self], user, profile)
    refute AccessLevels.can_access?(AccessLevels::LEVELS[:related], user, profile)
    assert AccessLevels.can_access?(AccessLevels::LEVELS[:users], user, profile)
    assert AccessLevels.can_access?(AccessLevels::LEVELS[:visitors], user, profile)
  end


  should 'allow visitors to access only visitors permission' do
    profile = fast_create(Profile)
    refute AccessLevels.can_access?(AccessLevels::LEVELS[:self], nil, profile)
    refute AccessLevels.can_access?(AccessLevels::LEVELS[:related], nil, profile)
    refute AccessLevels.can_access?(AccessLevels::LEVELS[:users], nil, profile)
    assert AccessLevels.can_access?(AccessLevels::LEVELS[:visitors], nil, profile)
  end
end

