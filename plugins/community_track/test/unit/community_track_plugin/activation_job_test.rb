require File.dirname(__FILE__) + '/../../test_helper'

class ActivationJobTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @track = create_track('track', @profile)
    @step = CommunityTrackPlugin::Step.new(:name => 'Step', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => Date.today, :start_date => Date.today)
    Delayed::Job.destroy_all
  end

  should 'return delayed job created with a specific step_id' do
    step_id = 0
    CommunityTrackPlugin::ActivationJob.new(step_id)
    assert CommunityTrackPlugin::ActivationJob.find(step_id)
  end

  should 'change publish to true on perform delayed job in a active step' do
    @step.start_date = Date.today
    @step.end_date = Date.today + 2.days
    @step.published = false
    @step.save!
    CommunityTrackPlugin::ActivationJob.new(@step.id).perform
    @step.reload
    assert @step.published
  end

  should 'reschedule delayed job after change publish to true' do
    @step.start_date = Date.today
    @step.end_date = Date.today + 2.days
    @step.published = false
    @step.save!
    assert_equal @step.start_date, Delayed::Job.first.run_at.to_date
    process_delayed_job_queue
    assert_equal @step.end_date + 1.day, Delayed::Job.first.run_at.to_date
  end

end
