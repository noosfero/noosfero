require_relative "../test_helper"

class ActivityNotificationsTest < ActiveSupport::TestCase

  def setup
    @follower = create_user.person
    @person = create_user.person
    @profile = fast_create(Community)

    @people_circle = fast_create(Circle, person_id: @follower.id, profile_type: 'Person', name: 'people')
    @profiles_circle = fast_create(Circle, person_id: @follower.id, profile_type: 'Community', name: 'profiles')
  end

  should 'create notifications for followers of the acitivty owner and display properly' do
    @follower.follow(@person, @people_circle)
    process_delayed_job_queue

    assert_difference '@follower.tracked_notifications.count' do
      Scrap.create(sender_id: @person.id, receiver_id: @profile.id, content: 'hello')
      process_delayed_job_queue
    end

    notification = @follower.tracked_notifications.last

    Person.any_instance.stubs(:wall_access).returns(AccessLevels.levels[:users])
    refute ActivityPresenter.for(notification).hidden_for?(@follower.user)

    Person.any_instance.stubs(:wall_access).returns(AccessLevels.levels[:related])
    assert ActivityPresenter.for(notification).hidden_for?(@follower.user)
  end

  should 'create notifications for followers of the activity target and display properly' do
    @follower.follow(@profile, @profiles_circle)
    process_delayed_job_queue

    assert_difference '@follower.tracked_notifications.count' do
      Scrap.create(sender_id: @person.id, receiver_id: @profile.id, content: 'hello')
      process_delayed_job_queue
    end

    notification = @follower.tracked_notifications.last

    Community.any_instance.stubs(:wall_access).returns(AccessLevels.levels[:users])
    refute ActivityPresenter.for(notification).hidden_for?(@follower.user)

    Community.any_instance.stubs(:wall_access).returns(AccessLevels::levels[:related])
    assert ActivityPresenter.for(notification).hidden_for?(@follower.user)
  end

  should 'create notifications and not display if the target disabled the followers feature' do
    @follower.follow(@person, @people_circle)
    process_delayed_job_queue

    Person.any_instance.stubs(:allow_followers?).returns(false)
    assert_difference '@follower.tracked_notifications.count' do
      Scrap.create(sender_id: @person.id, receiver_id: @profile.id, content: 'hello')
      process_delayed_job_queue
    end

    notification = @follower.tracked_notifications.last
    assert ActivityPresenter.for(notification).hidden_for?(@follower.user)
  end

  should 'notify community members just once' do
    @profile.add_member(@follower)
    process_delayed_job_queue

    assert_difference '@follower.tracked_notifications.count', 1 do
      Scrap.create(sender_id: @person.id, receiver_id: @profile.id, content: 'hello')
      process_delayed_job_queue
    end
  end
end
