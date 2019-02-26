require_relative "../test_helper"

class ActivitiesCounterCacheJobTest < ActiveSupport::TestCase

  should 'correctly update the person activities counter cache' do
    person = create_user('person').person
    ActionTracker::Record.create!(:user => person, :verb => 'create_article')
    ActionTracker::Record.create!(:user => person, :verb => 'create_article')
    person.reload
    assert_equal 2, person.activities_count

    person.activities_count = 0
    person.save!
    job = ActivitiesCounterCacheJob.new
    job.perform
    person.reload
    assert_equal 2, person.activities_count
  end

  should 'correctly update the organization activities counter cache' do
    person = create_user('person').person
    organization = Organization.create!(:name => 'Organization1', :identifier => 'organization1')
    ActionTracker::Record.create!(:user => person, :verb => 'create_article', :target => organization)
    ActionTracker::Record.create!(:user => person, :verb => 'create_article', :target => organization)
    organization.reload
    assert_equal 2, organization.activities_count

    organization.activities_count = 0
    organization.save!
    job = ActivitiesCounterCacheJob.new
    job.perform
    organization.reload
    assert_equal 2, organization.activities_count
  end

end
