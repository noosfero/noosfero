require_relative '../../test_helper'

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

  should 'change accept_comments to true on perform delayed job in a active step' do
    @step.start_date = Date.today
    @step.end_date = Date.today + 2.days
    @step.accept_comments = false
    @step.save!
    CommunityTrackPlugin::ActivationJob.new(@step.id).perform
    @step.reload
    assert @step.accept_comments
  end

end
