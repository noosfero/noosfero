require File.dirname(__FILE__) + '/../../test_helper'

class StepTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @track = CommunityTrackPlugin::Track.create(:profile_id => @profile.id, :name => 'track')
    @step = CommunityTrackPlugin::Step.new(:name => 'Step', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => Date.today, :start_date => Date.today)
    Delayed::Job.destroy_all
  end

  should 'describe yourself' do
    assert CommunityTrackPlugin::Step.description
  end

  should 'has a short description' do
    assert CommunityTrackPlugin::Step.short_description
  end
  
  should 'set published to false on create' do
    today = Date.today
    step = CommunityTrackPlugin::Step.create(:name => 'Step', :body => 'body', :profile => @profile, :parent => @track, :start_date => today, :end_date => today, :published => true)
    assert !step.published
  end

  should 'do not allow step creation with a parent that is not a track' do
    today = Date.today
    blog = fast_create(Blog)
    step = CommunityTrackPlugin::Step.new(:name => 'Step', :body => 'body', :profile => @profile, :parent => blog, :start_date => today, :end_date => today, :published => true)
    assert !step.save
  end
  
  should 'do not allow step creation without a parent' do
    today = Date.today
    step = CommunityTrackPlugin::Step.new(:name => 'Step', :body => 'body', :profile => @profile, :parent => nil, :start_date => today, :end_date => today, :published => true)
    assert !step.save
  end

  should 'create step if end date is equal to start date' do
    @step.start_date = Date.today
    @step.end_date = Date.today
    assert @step.save
  end

  should 'create step if end date is after start date' do
    @step.start_date = Date.today
    @step.end_date = Date.today + 1.day
    assert @step.save
  end

  should 'do not create step if end date is before start date' do
    @step.start_date = Date.today
    @step.end_date = Date.today - 1.day
    assert !@step.save
  end

  should 'do not validate date period if start date is nil' do
    @step.start_date = nil
    @step.end_date_equal_or_after_start_date.inspect
    assert [], @step.errors
  end

  should 'do not validate date period if end date is nil' do
    @step.end_date = nil
    @step.end_date_equal_or_after_start_date.inspect
    assert [], @step.errors
  end
  
  should 'be active if today is between start and end dates' do
    @step.start_date = Date.today
    @step.end_date = Date.today + 1.day
    assert @step.active?
  end
  
  should 'be finished if today is after the end date' do
    @step.start_date = Date.today - 2.day
    @step.end_date = Date.today - 1.day
    assert @step.finished?
  end
  
  should 'be waiting if today is before the end date' do
    @step.start_date = Date.today + 1.day
    @step.end_date = Date.today + 2.day
    assert @step.waiting?
  end
  
  should 'return delayed job created with a specific step_id' do
    step_id = 0
    CommunityTrackPlugin::ActivationJob.new(step_id)
    assert CommunityTrackPlugin::ActivationJob.find(step_id)
  end

  should 'create delayed job' do
    @step.start_date = Date.today
    @step.end_date = Date.today
    @step.schedule_activation
    assert_equal 1, Delayed::Job.count
    assert_equal @step.start_date, Delayed::Job.first.run_at.to_date
  end
  
  should 'do not duplicate delayed job' do
    @step.start_date = Date.today
    @step.end_date = Date.today
    @step.schedule_activation
    @step.schedule_activation
    assert_equal 1, Delayed::Job.count
  end
  
  should 'create delayed job when a step is saved' do
    @step.start_date = Date.today
    @step.end_date = Date.today
    @step.save!
    assert_equal @step.start_date, Delayed::Job.first.run_at.to_date
  end

  should 'create delayed job even if start date has passed' do
    @step.start_date = Date.today - 2.days
    @step.end_date = Date.today
    @step.schedule_activation
    assert_equal @step.start_date, Delayed::Job.first.run_at.to_date
  end

  should 'do not create delayed job if end date has passed and step is not published' do
    @step.start_date = Date.today - 5.days
    @step.end_date = Date.today - 2.days
    @step.published = false
    @step.schedule_activation
    assert_equal 0, Delayed::Job.count
  end

  should 'create delayed job if end date has passed and step is published' do
    @step.start_date = Date.today - 5.days
    @step.end_date = Date.today - 2.days
    @step.published = true
    @step.schedule_activation
    assert_equal @step.end_date + 1.day, Delayed::Job.first.run_at.to_date
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

  should 'do not schedule delayed job if save but do not modify date fields and published status' do
    @step.start_date = Date.today
    @step.end_date = Date.today 
    @step.published = false
    @step.save!
    assert_equal 1, Delayed::Job.count
    Delayed::Job.destroy_all
    @step.name = 'changed name'
    @step.save!
    assert_equal 0, Delayed::Job.count
  end

  should 'set position on save' do
    assert !@step.position
    @step.save!
    assert_equal 1, @step.position    
    step2 = CommunityTrackPlugin::Step.new(:name => 'Step2', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => Date.today, :start_date => Date.today)
    step2.save!
    assert_equal 2, step2.position    
  end

  should 'publish step if it is active' do
    @step.start_date = Date.today
    @step.save!
    assert !@step.published
    @step.publish
    @step.reload
    assert @step.published
  end

  should 'do not publish step if it is not active' do
    @step.start_date = Date.today + 2.days
    @step.end_date = Date.today + 3.days
    @step.save!
    assert !@step.published
    @step.publish
    @step.reload
    assert !@step.published
  end

  should 'unpublish step if it is not active anymore' do
    @step.start_date = Date.today
    @step.save!
    @step.publish
    @step.reload
    assert @step.published

    @step.start_date = Date.today - 2.days
    @step.end_date = Date.today - 1.day
    @step.save!
    @step.publish
    @step.reload
    assert !@step.published
  end

  should 'set position to zero if step is hidden' do
    @step.hidden = true
    @step.save!
    assert_equal 0, @step.position
  end

  should 'change position to zero if step becomes hidden' do
    @step.save!
    assert_equal 1, @step.position
    @step.hidden = true
    @step.save!
    assert_equal 0, @step.position
  end

  should 'change position to botton if a hidden step becomes visible' do
    step1 = CommunityTrackPlugin::Step.new(:name => 'Step1', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => Date.today, :start_date => Date.today)
    step1.save!
    @step.hidden = true
    @step.save!
    assert_equal 0, @step.position
    @step.hidden = false
    @step.save!
    assert_equal 2, @step.position
  end

  should 'decrement lower items positions if a step becomes hidden' do
    @step.save!
    step1 = CommunityTrackPlugin::Step.new(:name => 'Step1', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => Date.today, :start_date => Date.today)
    step1.save!
    assert_equal 2, step1.position
    @step.hidden = true
    @step.save!
    step1.reload
    assert_equal 1, step1.position
  end

  should 'do not publish a hidden step' do
    @step.start_date = Date.today
    @step.hidden = true
    @step.save!
    assert !@step.published
    @step.publish
    @step.reload
    assert !@step.published
  end

  should 'return enabled tools for a step' do
    assert_includes @step.enabled_tools, TinyMceArticle
    assert_includes @step.enabled_tools, Forum
  end

end
