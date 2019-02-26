require_relative "../test_helper"

class ActionTrackerExtTest < ActiveSupport::TestCase

  should 'increase person activities_count on new activity' do
    person = fast_create(Person)
    assert_difference 'person.activities_count', 1 do
      ActionTracker::Record.create! :verb => :leave_scrap, :user => person, :target => fast_create(Profile)
      person.reload
    end
  end

  should 'decrease person activities_count on activity removal' do
    person = fast_create(Person)
    record = ActionTracker::Record.create! :verb => :leave_scrap, :user => person, :target => fast_create(Profile)
    person.reload
    assert_difference 'person.activities_count', -1 do
      record.destroy
      person.reload
    end
  end

  should 'not decrease person activities_count on activity removal after the recent delay' do
    person = fast_create(Person)
    record = ActionTracker::Record.create! :verb => :leave_scrap, :user => person, :target => fast_create(Profile)
    record.created_at = record.created_at - ActionTracker::Record::RECENT_DELAY.days - 1.day
    record.save!
    person.reload
    assert_no_difference 'person.activities_count' do
      record.destroy
      person.reload
    end
  end

  should 'increase organization activities_count on new activity' do
    person = fast_create(Person)
    organization = fast_create(Organization)
    assert_difference 'organization.activities_count', 1 do
      ActionTracker::Record.create! :verb => :leave_scrap, :user => person, :target => organization
      organization.reload
    end
  end

  should 'decrease organization activities_count on activity removal' do
    person = fast_create(Person)
    organization = fast_create(Organization)
    record = ActionTracker::Record.create! :verb => :leave_scrap, :user => person, :target => organization
    organization.reload
    assert_difference 'organization.activities_count', -1 do
      record.destroy
      organization.reload
    end
  end

  should 'not decrease organization activities_count on activity removal after the recent delay' do
    person = fast_create(Person)
    organization = fast_create(Organization)
    record = create(ActionTracker::Record, :verb => :leave_scrap, :user => person, :target => organization, :created_at => (ActionTracker::Record::RECENT_DELAY + 1).days.ago)
    organization.reload
    assert_no_difference 'organization.activities_count' do
      record.destroy
      organization.reload
    end
  end

  should 'create profile activity' do
    person = fast_create(Profile)
    organization = fast_create(Enterprise)
    record = create ActionTracker::Record, :verb => :create_product, :user => person, :target => organization
    assert_equal record, organization.activities.first.activity
  end

end
