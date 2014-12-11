require File.dirname(__FILE__) + '/../test_helper'

class ContentViewerController
  append_view_path File.join(File.dirname(__FILE__) + '/../../views')
  def rescue_action(e)
    raise e
  end
end

class ContentViewerControllerTest < ActionController::TestCase

  def setup
    @profile = Community.create!(:name => 'Sample community', :identifier => 'sample-community')
    @track = create_track('track', @profile)
    @step = CommunityTrackPlugin::Step.create!(:name => 'step1', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => Date.today, :start_date => Date.today, :tool_type => TinyMceArticle.name)

    user = create_user('testinguser')
    login_as(user.login)
    @profile.add_admin(user.person)
  end

  should 'show actions for tracks when user has permission for edit' do
    get :view_page, @track.url
    assert_tag :tag => 'div', :attributes => {:id => 'track' }, :descendant => { :tag => 'div', :attributes => { :class => 'track actions' } }
  end

  should 'do not show actions for tracks when user has not permission to edit' do
    user = create_user('intruder')
    logout
    login_as(user.login)
    get :view_page, @track.url
    assert_no_tag :tag => 'div', :attributes => {:id => 'track' }, :descendant => { :tag => 'div', :attributes => { :class => 'track actions' } }
  end

  should 'do not show new button at article toolbar for tracks' do
    user = create_user('intruder')
    logout
    login_as(user.login)
    get :view_page, @track.url
    assert_no_tag :tag => 'div', :attributes => {:id => 'article-actions'}, :descendant => { :tag => 'div', :attributes => { :id => 'icon-new' } }
  end

  should 'display steps for tracks' do
    get :view_page, @track.url
    assert_tag :tag => 'ul', :attributes => { :id => 'sortable' }, :descendant => {:tag => 'li', :attributes => { :class => 'step step_active' } }
  end

  should 'display hidden field with step id' do
    get :view_page, @track.url
    assert_tag :tag => 'input', :attributes => { :name => 'step_ids[]' }
  end

  should 'show step' do
    get :view_page, @step.url
    assert_tag :tag => 'div', :attributes => { :id => 'step' }
  end

  should 'show tools for a step' do
    TinyMceArticle.create!(:profile => @profile, :name => 'article', :parent => @step)
    get :view_page, @step.url
    assert_tag :tag => 'div', :attributes => { :class => 'tools' }, :descendant => { :tag => 'div', :attributes => { :class => 'item' } }
  end

  should 'show actions for steps when user has permission to edit' do
    get :view_page, @step.url
    assert_tag :tag => 'div', :attributes => {:id => 'step' }, :descendant => { :tag => 'div', :attributes => { :class => 'actions' } }
  end

  should 'show action for tiny mce article tool in step' do
    get :view_page, @step.url
    assert_tag 'div', :attributes => {:class => 'actions' }, :descendant => { :tag => 'a', :attributes => { :class => 'button with-text icon-new icon-newtext-html' } }
  end

  should 'show action for forum tool in step' do
    @step.tool_type = Forum.name
    @step.save!
    get :view_page, @step.url
    assert_tag 'div', :attributes => {:class => 'actions' }, :descendant => { :tag => 'a', :attributes => { :class => 'button with-text icon-new icon-newforum' } }
  end

  should 'do not show actions for steps when user has not permission for edit' do
    user = create_user('intruder')
    logout
    login_as(user.login)
    get :view_page, @step.url
    assert_no_tag :tag => 'div', :attributes => {:id => 'step' }, :descendant => { :tag => 'div', :attributes => { :class => 'actions' } }
  end

  should 'render a div with block id for track list block' do
    @block = CommunityTrackPlugin::TrackListBlock.create!(:box => @profile.boxes.last)
    get :view_page, @step.url
    assert_tag :tag => 'div', :attributes => { :class => 'track_list', :id => "track_list_#{@block.id}" }
  end

  should 'render a div with block id for track card list block' do
    @block = CommunityTrackPlugin::TrackCardListBlock.create!(:box => @profile.boxes.last)
    get :view_page, @step.url
    assert_tag :tag => 'div', :attributes => { :class => 'track_list', :id => "track_list_#{@block.id}" }
  end

  should 'render tracks in track list block' do
    @block = CommunityTrackPlugin::TrackListBlock.create!(:box => @profile.boxes.last)
    get :view_page, @step.url
    assert_tag :tag => 'div', :attributes => { :class => "item category_#{@track.category_name}" }, :descendant => { :tag => 'div', :attributes => { :class => 'steps' }, :descendant => { :tag => 'span', :attributes => { :class => "step #{@block.status_class(@step)}" } } }
  end

  should 'render tracks in track card list block' do
    @block = CommunityTrackPlugin::TrackCardListBlock.create!(:box => @profile.boxes.last)
    get :view_page, @step.url
    assert_tag :tag => 'div', :attributes => { :class => "item_card category_#{@track.category_name}" }, :descendant => { :tag => 'div', :attributes => { :class => 'track_content' } }
    assert_tag :tag => 'div', :attributes => { :class => "item_card category_#{@track.category_name}" }, :descendant => { :tag => 'div', :attributes => { :class => 'track_stats' } }
  end

  should 'render link to display more tracks in track list block' do
    @block = CommunityTrackPlugin::TrackCardListBlock.create!(:box => @profile.boxes.last)
    (@block.limit+1).times { |i| create_track("track#{i}", @profile) }

    get :view_page, @step.url
    assert_tag :tag => 'div', :attributes => { :id => "track_list_more_#{@block.id}" }, :descendant => { :tag => 'div', :attributes => { :class => 'more' } }
  end

  should 'render link to show all tracks in track list block' do
    @block = CommunityTrackPlugin::TrackCardListBlock.create!(:box => @profile.boxes.last)
    @block.more_another_page = true
    @block.save!

    (@block.limit+1).times { |i| create_track("track#{i}", @profile) }

    get :view_page, @step.url
    assert_tag :tag => 'div', :attributes => { :id => "track_list_more_#{@block.id}" }, :descendant => { :tag => 'div', :attributes => { :class => 'view_all' } }
  end

end
