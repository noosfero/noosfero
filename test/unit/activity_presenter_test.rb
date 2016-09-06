require_relative "../test_helper"

class ActivityPresenterTest < ActiveSupport::TestCase
  should 'be available for ActionTracker::Record' do
    assert ActivityPresenter.available?(ActionTracker::Record.new)
  end

  should 'be available for ProfileActivity' do
    assert ActivityPresenter.available?(ProfileActivity.new)
  end

  should 'return correct target for ActionTracker::Record' do
    target = mock
    activity = ActionTracker::Record.new
    activity.stubs(:target).returns(target)
    assert_equal target, ActivityPresenter.target(activity)
  end

  should 'return correct target for ProfileActivity' do
    target = mock
    notification = ProfileActivity.new
    record = ActionTracker::Record.new
    notification.stubs(:activity).returns(record)
    record.stubs(:target).returns(target)

    assert_equal target, ActivityPresenter.target(notification)
  end

  should 'return correct owner for ActionTracker::Record' do
    owner = mock
    activity = ActionTracker::Record.new
    activity.stubs(:user).returns(owner)
    assert_equal owner, ActivityPresenter.owner(activity)
  end

  should 'return correct owner for ProfileActivity' do
    owner = mock
    notification = ProfileActivity.new
    notification.stubs(:profile).returns(owner)

    assert_equal owner, ActivityPresenter.owner(notification)
  end

  should 'not be hidden for user if target does not respond to display_to' do
    user = fast_create(Person)
    target = mock
    presenter = ActivityPresenter.new(target)
    refute presenter.hidden_for?(user)
  end

  should 'be hidden for user based on target display_to' do
    user = fast_create(Person)
    target = mock
    presenter = ActivityPresenter.new(target)

    target.stubs(:display_to?).with(user).returns(false)
    assert presenter.hidden_for?(user)

    target.stubs(:display_to?).with(user).returns(true)
    refute presenter.hidden_for?(user)
  end

  should 'verify if user is involved as target with the activity' do
    user = mock
    presenter = ActivityPresenter.new(mock)
    presenter.stubs(:target).returns(user)
    presenter.stubs(:owner).returns(nil)
    assert presenter.involved?(user)
  end

  should 'verify if user is involved as owner with the activity' do
    user = mock
    presenter = ActivityPresenter.new(mock)
    presenter.stubs(:target).returns(nil)
    presenter.stubs(:owner).returns(user)
    assert presenter.involved?(user)
  end

  should 'refute if user is not involved' do
    user = mock
    presenter = ActivityPresenter.new(mock)
    presenter.stubs(:target).returns(nil)
    presenter.stubs(:owner).returns(nil)
    refute presenter.involved?(user)
  end
end
