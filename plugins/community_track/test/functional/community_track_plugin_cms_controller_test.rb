require_relative '../test_helper'

class CmsControllerTest < ActionController::TestCase

  def setup
    @profile = fast_create(Community)
    @track = create_track('track', @profile)
    @step = CommunityTrackPlugin::Step.create!(:name => 'step1', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => Date.today, :start_date => Date.today)

    user = create_user('testinguser')
    @profile.add_admin(user.person)
    login_as(user.login)
  end

  should 'be able to edit track' do
    get :edit, :id => @track.id, :profile => @profile.identifier
    assert_tag :tag => 'input', :attributes => { :id => 'article_name' }
  end

  should 'be able to edit step' do
    get :edit, :id => @step.id, :profile => @profile.identifier
    assert_tag :tag => 'input', :attributes => { :id => 'article_name' }
  end

  should 'be able to save track' do
    get :edit, :id => @track.id, :profile => @profile.identifier
    post :edit, :id => @track.id, :profile => @profile.identifier, :article => {:name => 'changed'}
    @track.reload
    assert_equal 'changed', @track.name
  end

  should 'be able to save step' do
    get :edit, :id => @step.id, :profile => @profile.identifier
    post :edit, :id => @step.id, :profile => @profile.identifier, :article => {:name => 'changed'}
    @step.reload
    assert_equal 'changed', @step.name
  end

end
