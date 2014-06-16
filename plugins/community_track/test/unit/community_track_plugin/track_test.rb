require File.dirname(__FILE__) + '/../../test_helper'

class TrackTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @track = create_track('track', @profile)
    @step = CommunityTrackPlugin::Step.create!(:parent => @track, :start_date => Date.today, :end_date => Date.today, :name => 'step', :profile => @profile)
    @tool = fast_create(Article, :parent_id => @step.id, :profile_id => @profile.id)
  end

  should 'describe yourself' do
    assert CommunityTrackPlugin::Track.description
  end

  should 'has a short descriptionf' do
    assert CommunityTrackPlugin::Track.short_description
  end

  should 'has a css class name' do
    assert_equal 'community-track-plugin-track', @track.css_class_name
  end

  should 'return comments count of children tools' do
    assert_equal 0, @track.comments_count
    owner = create_user('testuser').person
    article = create(Article, :name => 'article', :parent_id => @step.id, :profile_id => owner.id)
    comment = create(Comment, :source => article, :author_id => owner.id)
    assert_equal 1, @track.comments_count
  end

  should 'return children steps' do
    assert_equal [@step], @track.steps_unsorted
  end

  should 'do not return other articles type at steps' do
    article = fast_create(Article, :parent_id => @track.id, :profile_id => @track.profile.id)
    assert_includes @track.children, article
    assert_equal [@step], @track.steps_unsorted
  end

  should 'return name of the top category' do
    top = fast_create(Category, :name => 'top category')
    category1 = fast_create(Category, :name => 'category1', :parent_id => top.id )
    category2 = fast_create(Category, :name => 'category2', :parent_id => category1.id )
    @track.categories.delete_all
    @track.add_category(category2, true)
    assert_equal 'top category', @track.category_name
  end

  should 'return empty for category name if it has no category' do
    @track.categories.delete_all
    assert_equal '', @track.category_name
  end

  should 'return category name of first category' do
    category = fast_create(Category, :name => 'category')
    @track.categories.delete_all
    @track.add_category(category, true)
    category2 = fast_create(Category, :name => 'category2')
    @track.add_category(category2, true)
    assert_equal 'category', @track.category_name
  end

  should 'return steps with insert order' do
    @track.children.destroy_all
    step1 = CommunityTrackPlugin::Step.create!(:parent => @track, :start_date => Date.today, :end_date => Date.today, :name => "step1", :profile => @track.profile)
    step2 = CommunityTrackPlugin::Step.create!(:parent => @track, :start_date => Date.today, :end_date => Date.today, :name => "step2", :profile => @track.profile)
    step3 = CommunityTrackPlugin::Step.create!(:parent => @track, :start_date => Date.today, :end_date => Date.today, :name => "step3", :profile => @track.profile)
    assert_equal 1, step1.position
    assert_equal 2, step2.position
    assert_equal 3, step3.position
    assert_equal [step1, step2, step3], @track.steps
  end

  should 'return steps with order defined by position attribute' do
    @track.children.destroy_all
    step1 = CommunityTrackPlugin::Step.create!(:parent => @track, :start_date => Date.today, :end_date => Date.today, :name => "step1", :profile => @track.profile)
    step2 = CommunityTrackPlugin::Step.create!(:parent => @track, :start_date => Date.today, :end_date => Date.today, :name => "step2", :profile => @track.profile)
    step3 = CommunityTrackPlugin::Step.create!(:parent => @track, :start_date => Date.today, :end_date => Date.today, :name => "step3", :profile => @track.profile)
    step1.position = 3
    step1.save!
    step2.position = 1
    step2.save!
    step3.position = 2
    step3.save!
    assert_equal [step2, step3, step1], @track.steps
  end

  should 'save steps in a new order' do
    @track.children.destroy_all

    step1 = CommunityTrackPlugin::Step.create!(:parent => @track, :start_date => Date.today, :end_date => Date.today, :name => "step1", :profile => @track.profile)
    step2 = CommunityTrackPlugin::Step.create!(:parent => @track, :start_date => Date.today, :end_date => Date.today, :name => "step2", :profile => @track.profile)
    step3 = CommunityTrackPlugin::Step.create!(:parent => @track, :start_date => Date.today, :end_date => Date.today, :name => "step3", :profile => @track.profile)

    assert_equal [step1.id, step2.id, step3.id], @track.steps.map(&:id)
    @track.reorder_steps([step3.id, step1.id, step2.id])
    @track.reload
    assert_equal [step3.id, step1.id, step2.id], @track.steps.map(&:id)
  end

  should 'do not return hidden steps' do
    hidden_step = CommunityTrackPlugin::Step.new(:parent => @track, :start_date => Date.today, :end_date => Date.today, :name => 'hidden step', :profile => @track.profile)
    hidden_step.hidden = true
    hidden_step.save!
    assert_equal [@step], @track.steps
  end

  should 'return hidden steps' do
    hidden_step = CommunityTrackPlugin::Step.new(:parent => @track, :start_date => Date.today, :end_date => Date.today, :name => 'hidden step', :profile => @track.profile)
    hidden_step.hidden = true
    hidden_step.save!
    assert_equal [hidden_step], @track.hidden_steps
  end

   should 'get first paragraph' do
    @track.body = '<p>First</p><p>Second</p>'
    assert_equal '<p>First</p>', @track.first_paragraph
  end

  should 'provide first_paragraph even if body was not given' do
    assert_equal '', @track.first_paragraph
  end

  should 'provide first_paragraph even if body is nil' do
    @track.body = nil
    assert_equal '', @track.first_paragraph
  end

  should 'not be able to create a track without category' do
    track = CommunityTrackPlugin::Track.create(:profile => @profile, :name => 'track')
    assert track.errors.include?(:categories)
  end

  should 'not be able to save a track without category' do
    @track.categories.delete_all
    @track.save
    assert @track.errors.include?(:categories)
  end

end
