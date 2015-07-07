require_relative '../test_helper'
require_relative '../../controllers/myprofile/community_track_plugin_myprofile_controller'

class CommunityTrackPluginMyprofileControllerTest < ActionController::TestCase

  def setup
    @profile = fast_create(Community)
    @track = create_track('track', @profile)

    @user = create_user('testinguser')
    login_as(@user.login)
    @profile.add_admin(@user.person)
  end

  should 'redirect to track on save order' do
    get :save_order, :profile => @profile.identifier, :track => @track.id, :step_ids => []
    assert_redirected_to @track.url
  end

  should 'save new step positions on save order' do
    step1 = CommunityTrackPlugin::Step.create!(:name => 'step1', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => Date.today, :start_date => Date.today)
    step2 = CommunityTrackPlugin::Step.create!(:name => 'step2', :body => 'body', :profile => @profile, :parent => @track, :published => false, :end_date => Date.today, :start_date => Date.today)
    assert_equal [step1, step2], @track.steps
    get :save_order, :profile => @profile.identifier, :track => @track.id, :step_ids => [step2.id, step1.id]
    assert_equal [step2, step1], @track.steps
  end

  should 'do not allow a user without permission to save order' do
    logout
    user = create_user('intruder')
    login_as(user.login)
    get :save_order, :profile => @profile.identifier, :track => @track.id, :step_ids => []
    assert_response 403
  end

  should 'redirect to login page if there is no user logged in' do
    logout
    get :save_order, :profile => @profile.identifier, :track => @track.id, :step_ids => []
    assert_response 302
  end

end
