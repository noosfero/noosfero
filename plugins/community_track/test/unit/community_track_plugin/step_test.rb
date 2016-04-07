require_relative '../../test_helper'

class StepTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @track = CommunityTrackPlugin::Track.new(:profile => @profile, :name => 'track')
    @category = fast_create(Category)
    @track.add_category(@category)
    @track.save!

    @step = CommunityTrackPlugin::Step.new(:name => 'Step', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => DateTime.now.end_of_day, :start_date => DateTime.now.beginning_of_day - 1.day)
    Delayed::Job.destroy_all
  end

  should 'describe yourself' do
    assert CommunityTrackPlugin::Step.description
  end

  should 'has a short description' do
    assert CommunityTrackPlugin::Step.short_description
  end

  should 'set accept_comments to false on create' do
    today = DateTime.now
    step = CommunityTrackPlugin::Step.create(:name => 'Step', :body => 'body', :profile => @profile, :parent => @track, :start_date => today, :end_date => today, :published => true)
    refute step.accept_comments
  end

  should 'do not allow step creation with a parent that is not a track' do
    today = DateTime.now
    blog = fast_create(Blog)
    step = CommunityTrackPlugin::Step.new(:name => 'Step', :body => 'body', :profile => @profile, :parent => blog, :start_date => today, :end_date => today, :published => true)
    refute step.save
  end

  should 'do not allow step creation without a parent' do
    today = DateTime.now
    step = CommunityTrackPlugin::Step.new(:name => 'Step', :body => 'body', :profile => @profile, :parent => nil, :start_date => today, :end_date => today, :published => true)
    refute step.save
  end

  should 'create step if end date is equal to start date' do
    @step.start_date = DateTime.now
    @step.end_date = DateTime.now
    assert @step.save
  end

  should 'create step if end date is after start date' do
    @step.start_date = DateTime.now
    @step.end_date = DateTime.now + 1.day
    assert @step.save
  end

  should 'do not create step if end date is before start date' do
    @step.start_date = DateTime.now
    @step.end_date = DateTime.now - 1.day
    refute @step.save
  end

  should 'do not validate date period if start date is nil' do
    @step.start_date = nil
    @step.end_date_equal_or_after_start_date.inspect
    assert @step.errors.empty?
  end

  should 'do not validate date period if end date is nil' do
    @step.end_date = nil
    @step.end_date_equal_or_after_start_date.inspect
    assert @step.errors.empty?
  end

  should 'be active if today is between start and end dates' do
    @step.start_date = DateTime.now
    @step.end_date = DateTime.now + 1.day
    assert @step.active?
  end

  should 'be finished if today is after the end date' do
    @step.start_date = DateTime.now - 2.day
    @step.end_date = DateTime.now - 1.day
    assert @step.finished?
  end

  should 'be waiting if today is before the end date' do
    @step.start_date = DateTime.now + 1.day
    @step.end_date = DateTime.now + 2.day
    assert @step.waiting?
  end

  should 'return delayed job created with a specific step_id' do
    step_id = 0
    CommunityTrackPlugin::ActivationJob.new(step_id)
    assert CommunityTrackPlugin::ActivationJob.find(step_id)
  end

  should 'create delayed job' do
    @step.start_date = DateTime.now.beginning_of_day
    @step.end_date = DateTime.now.end_of_day
    @step.accept_comments = false
    @step.schedule_activation
    assert_equal 1, Delayed::Job.count
    assert_equal @step.start_date, Delayed::Job.first.run_at
  end

  should 'do not duplicate delayed job' do
    @step.start_date = DateTime.now
    @step.end_date = DateTime.now
    @step.schedule_activation
    assert_equal 1, Delayed::Job.count
    @step.schedule_activation
    assert_equal 1, Delayed::Job.count
  end

  should 'create delayed job when a step is saved' do
    @step.start_date = DateTime.now.beginning_of_day
    @step.end_date = DateTime.now.end_of_day
    @step.save!
    assert_equal @step.start_date, Delayed::Job.first.run_at
  end

  should 'create delayed job even if start date has passed' do
    @step.start_date = DateTime.now - 2.days
    @step.end_date = DateTime.now.end_of_day
    @step.accept_comments = false
    @step.schedule_activation
    assert_in_delta @step.start_date, Delayed::Job.first.run_at
  end

  should 'create delayed job if end date has passed' do
    @step.start_date = DateTime.now - 5.days
    @step.end_date = DateTime.now - 2.days
    @step.schedule_activation
    assert_in_delta @step.end_date + 1.day, Delayed::Job.first.run_at
  end

  should 'do not schedule delayed job if save but do not modify date fields' do
    @step.start_date = DateTime.now
    @step.end_date = DateTime.now.end_of_day
    @step.save!
    assert_equal 1, Delayed::Job.count
    Delayed::Job.destroy_all
    @step.name = 'changed name'
    @step.save!
    assert_equal 0, Delayed::Job.count
  end

  should 'set position on save' do
    refute @step.position
    @step.save!
    assert_equal 1, @step.position
    step2 = CommunityTrackPlugin::Step.new(:name => 'Step2', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => DateTime.now.end_of_day, :start_date => DateTime.now.beginning_of_day)
    step2.save!
    assert_equal 2, step2.position
  end

  should 'accept comments if step is active' do
    @step.start_date = DateTime.now
    @step.save!
    refute @step.accept_comments
    @step.toggle_activation
    @step.reload
    assert @step.accept_comments
  end

  should 'do not accept comments if step is not active' do
    @step.start_date = DateTime.now + 2.days
    @step.end_date = DateTime.now + 3.days
    @step.save!
    refute @step.published
    @step.toggle_activation
    @step.reload
    refute @step.published
  end

  should 'do not accept comments if step is not active anymore' do
    @step.end_date = DateTime.now.end_of_day
    @step.save!
    @step.toggle_activation
    @step.reload
    assert @step.accept_comments

    @step.start_date = DateTime.now - 2.days
    @step.end_date = DateTime.now - 1.day
    @step.save!
    @step.toggle_activation
    @step.reload
    refute @step.accept_comments
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
    step1 = CommunityTrackPlugin::Step.new(:name => 'Step1', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => DateTime.now.end_of_day, :start_date => DateTime.now.beginning_of_day)
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
    step1 = CommunityTrackPlugin::Step.new(:name => 'Step1', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => DateTime.now.end_of_day, :start_date => DateTime.now.beginning_of_day)
    step1.save!
    assert_equal 2, step1.position
    @step.hidden = true
    @step.save!
    step1.reload
    assert_equal 1, step1.position
  end

  should 'do not publish a hidden step' do
    @step.start_date = DateTime.now
    @step.hidden = true
    @step.save!
    refute @step.published
    @step.toggle_activation
    @step.reload
    refute @step.published
  end

  should 'return enabled tools for a step' do
    assert_includes @step.enabled_tools, TinyMceArticle
    assert_includes @step.enabled_tools, Forum
  end

  should 'return class for selected tool' do
    @step.tool_type = 'Forum'
    assert_equal Forum, @step.tool_class
  end

  should 'return tool for selected type' do
    @step.tool_type = 'Forum'
    @step.save!
    article = fast_create(Article, :parent_id => @step.id)
    forum = fast_create(Forum, :parent_id => @step.id)
    assert_equal forum, @step.tool
  end

  should 'not return tool with different type' do
    @step.tool_type = 'Forum'
    @step.save!
    article = fast_create(Article, :parent_id => @step.id)
    assert_not_equal article, @step.tool
  end

  should 'initialize start date and end date with default values' do
    step = CommunityTrackPlugin::Step.new
    assert step.start_date
    assert step.end_date
  end

  should 'enable comments on children when step is activated' do
    @step.start_date = DateTime.now
    @step.save!
    refute @step.accept_comments
    article = fast_create(Article, :parent_id => @step.id, :profile_id => @step.profile.id, :accept_comments => false)
    refute article.accept_comments
    @step.toggle_activation
    assert article.reload.accept_comments
  end

  should 'enable comments on children when step is active' do
    @step.start_date = DateTime.now
    @step.save!
    refute @step.accept_comments
    @step.toggle_activation
    article = Article.create!(:parent => @step, :profile => @step.profile, :accept_comments => false, :name => "article")
    assert article.reload.accept_comments
  end

end
