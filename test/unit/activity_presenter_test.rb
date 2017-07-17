require_relative "../test_helper"

class ActivityPresenterTest < ActiveSupport::TestCase
  def setup
    @user = fast_create(Person)
    @target = mock
    @owner = mock

    @target.stubs(:wall_access).returns(AccessLevels.levels[:users])
  end

  should 'be available for ActionTracker::Record' do
    assert ActivityPresenter.available?(ActionTracker::Record.new)
  end

  should 'be available for ProfileActivity' do
    assert ActivityPresenter.available?(ProfileActivity.new)
  end

  should 'return correct target for ActionTracker::Record' do
    activity = ActionTracker::Record.new
    activity.stubs(:target).returns(@target)
    assert_equal @target, ActivityPresenter.target(activity)
  end

  should 'return correct target for ProfileActivity' do
    notification = ProfileActivity.new
    record = ActionTracker::Record.new
    notification.stubs(:activity).returns(record)
    record.stubs(:target).returns(@target)

    assert_equal @target, ActivityPresenter.target(notification)
  end

  should 'return correct owner for ActionTracker::Record' do
    activity = ActionTracker::Record.new
    activity.stubs(:user).returns(@owner)
    assert_equal @owner, ActivityPresenter.owner(activity)
  end

  should 'return correct owner for ProfileActivity' do
    notification = ProfileActivity.new
    notification.stubs(:profile).returns(@owner)

    assert_equal @owner, ActivityPresenter.owner(notification)
  end

  should 'not be hidden for user if target does not respond to display_to' do
    presenter = ActivityPresenter.new(@target)

    AccessLevels.stubs(:can_access?).returns(true)
    @target.stubs(:is_a?).with(Profile).returns(true)
    @target.stubs(:allow_followers?).returns(true)

    refute presenter.hidden_for?(@user)
  end

  should 'be hidden for user based on target display_to' do
    presenter = ActivityPresenter.new(@target)
    AccessLevels.stubs(:can_access?).returns(true)
    @target.stubs(:is_a?).with(Profile).returns(true)
    @target.stubs(:allow_followers?).returns(true)

    @target.stubs(:display_to?).with(@user).returns(false)
    assert presenter.hidden_for?(@user)

    @target.stubs(:display_to?).with(@user).returns(true)
    refute presenter.hidden_for?(@user)
  end

  should 'be hidden if user disabled the followers feature' do
    presenter = ActivityPresenter.new(@target)
    AccessLevels.stubs(:can_access?).returns(true)
    @target.stubs(:is_a?).with(Profile).returns(true)
    @target.stubs(:display_to?).with(@user).returns(true)

    @target.stubs(:allow_followers?).returns(false)
    assert presenter.hidden_for?(@user)

    @target.stubs(:allow_followers?).returns(true)
    refute presenter.hidden_for?(@user)
  end

  should 'verify if user is involved as target with the activity' do
    user = mock
    presenter = ActivityPresenter.new(@target)
    presenter.stubs(:target).returns(user)
    presenter.stubs(:owner).returns(nil)
    assert presenter.involved?(user)
  end

  should 'verify if user is involved as owner with the activity' do
    user = mock
    presenter = ActivityPresenter.new(@target)
    presenter.stubs(:target).returns(nil)
    presenter.stubs(:owner).returns(user)
    assert presenter.involved?(user)
  end

  should 'refute if user is not involved' do
    user = mock
    presenter = ActivityPresenter.new(@target)
    presenter.stubs(:target).returns(nil)
    presenter.stubs(:owner).returns(nil)
    refute presenter.involved?(user)
  end

  should 'be hidden if the target is a profile with a restricted wall' do
    target = create_user.person
    presenter = ActivityPresenter.new(target)

    Person.any_instance.stubs(:wall_access).returns(AccessLevels.levels[:related])
    assert presenter.hidden_for?(@user)
  end

  should 'not be hidden if the target is a profile with a public wall' do
    target = create_user.person
    presenter = ActivityPresenter.new(target)

    Person.any_instance.stubs(:wall_access).returns(AccessLevels.levels[:users])
    refute presenter.hidden_for?(@user)
  end

  should 'be hidden if the target is an article whose profile has a restricted wall' do
    profile = fast_create(Community)
    article = fast_create(Article, profile_id: profile.id)
    presenter = ActivityPresenter.new(article)

    Community.any_instance.stubs(:wall_access).returns(AccessLevels.levels[:related])
    assert presenter.hidden_for?(@user)
  end

  should 'not be hidden if the target is an article whose profile has a public wall' do
    profile = fast_create(Community)
    article = fast_create(Article, profile_id: profile.id)
    presenter = ActivityPresenter.new(article)

    Community.any_instance.stubs(:wall_access).returns(AccessLevels.levels[:users])
    refute presenter.hidden_for?(@user)
  end

  should 'be hidden if the target is a scrap whose receiver has a restricted wall' do
    receiver = create_user.person
    scrap = fast_create(Scrap, receiver_id: receiver.id)
    presenter = ActivityPresenter.new(scrap)

    Person.any_instance.stubs(:wall_access).returns(AccessLevels.levels[:related])
    assert presenter.hidden_for?(@user)
  end

  should 'not be hidden if the target is a scrap whose receiver has a public wall' do
    receiver = create_user.person
    scrap = fast_create(Scrap, receiver_id: receiver.id)
    presenter = ActivityPresenter.new(scrap)

    Person.any_instance.stubs(:wall_access).returns(AccessLevels.levels[:users])
    refute presenter.hidden_for?(@user)
  end

  should 'use the owner as target profile if the target class is unknown' do
    target = fast_create(ProfileFollower, profile_id: @user.id)
    presenter = ActivityPresenter.new(target)

    presenter.expects(:owner).at_least(1).returns(@owner)
    @owner.expects(:wall_access).returns(AccessLevels.levels[:users])
    AccessLevels.expects(:can_access?).returns(false)
    presenter.hidden_for?(@user)
  end
end
