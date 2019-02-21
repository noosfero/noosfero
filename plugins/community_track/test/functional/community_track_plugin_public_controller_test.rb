require_relative '../test_helper'
require_relative '../../controllers/public/community_track_plugin_public_controller'

class CommunityTrackPluginPublicControllerTest < ActionDispatch::IntegrationTest

  def setup
    @community = fast_create(Community)
    @track = create_track('track', @community)

    box = fast_create(Box, :owner_id => @community.id, :owner_type => 'Community')
    @card_block = create(CommunityTrackPlugin::TrackCardListBlock, :box => box)
    @block = create(CommunityTrackPlugin::TrackListBlock, :box => box)
  end

  should 'display tracks for card block' do
    get  community_track_plugin_public_path(action: :view_tracks), params: {:id => @card_block.id, :page => 1}, xhr: true
    assert_match /track_list_#{@card_block.id}/, @response.body
  end

  should 'display tracks for list block' do
    get community_track_plugin_public_path(action: :view_tracks), params: {:id => @block.id, :page => 1}, xhr: true
    assert_match /track_list_#{@block.id}/, @response.body
  end

  should 'display tracks with page size' do
    20.times { |i| create_track("track#{i}", @community) }
    get community_track_plugin_public_path(action: :view_tracks), params: {:id => @block.id, :page => 1, :per_page => 10}, xhr: true
    assert_equal 10, @response.body.scan(/item/).size
  end

  should 'default page size is the block limit' do
    20.times { |i| create_track("track#{i}", @community) }
    get community_track_plugin_public_path(action: :view_tracks), params: {:id => @block.id, :page => 1}, xhr: true
    assert_equal @block.limit, @response.body.scan(/item/).size
  end

  should 'display page for all tracks' do
    get community_track_plugin_public_path(action: :all_tracks), params: {:id => @block.id}, xhr: true
    assert_match /track_list_#{@block.id}/, @response.body
  end

  should 'show more link in all tracks if there is no more tracks to show' do
    10.times { |i| create_track("track#{i}", @community) }
    get community_track_plugin_public_path(action: :all_tracks), params: {:id => @block.id}
    assert assigns['show_more']
    assert_match /track_list_more_#{@block.id}/, @response.body
  end

  should 'do not show more link in all tracks if there is no more tracks to show' do
    CommunityTrackPlugin::Track.destroy_all
    get community_track_plugin_public_path(action: :all_tracks), params: {:id => @block.id}
    refute assigns['show_more']
    assert_no_match /track_list_more_#{@block.id}/, @response.body
  end

  should 'show select community page if user is logged in' do
    user = create_user('testinguser')
    login_as_rails5(user.login)
    get community_track_plugin_public_path(action: :select_community)
    assert_template 'select_community'
  end

  should 'redirect to login page if user try to access community selection' do
    logout_rails5
    get community_track_plugin_public_path(action: :select_community)
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  should 'display for selection communities where user has permission to post content' do
    user = create_user('testinguser')
    login_as_rails5(user.login)
    @community.add_member(user.person)
    get community_track_plugin_public_path(action: :select_community)
    assert_tag :tag => 'li', :attributes => {:class => 'search-profile-item'}
    assert_tag :tag => 'input', :attributes => {:id => "community_identifier_#{@community.identifier}"}
  end

  should 'do not display communities where user has not permission to post content' do
    user = create_user('testinguser')
    login_as_rails5(user.login)
    get community_track_plugin_public_path(action: :select_community)
    !assert_tag :tag => 'input', :attributes => {:id => "community_identifier_#{@community.identifier}"}
  end

  should 'redirect to new content with track content type' do
    user = create_user('testinguser')
    login_as_rails5(user.login)
    post community_track_plugin_public_path(action: :select_community), params: {:profile => user.person.identifier, :community_identifier => @community.identifier}
    assert_redirected_to :controller => 'cms', :action => 'new', :type => "CommunityTrackPlugin::Track", :profile => @community.identifier
  end

  should 'return error message if user do not select a community' do
    user = create_user('testinguser')
    login_as_rails5(user.login)
    post community_track_plugin_public_path(action: :select_community), params: {:profile => user.person.identifier, community_identifier: nil }
    assert_equal 1, assigns(:failed).count
    assert_tag :tag => 'div', :attributes => {:id => 'errorExplanation'}
  end

  #FIXME see a way to test without session
#  should 'do not repeat tracks when paging a block with random order' do
#    CommunityTrackPlugin::Track.destroy_all
#    @block.order = 'random'
#    @block.save!
#
#    per_page = 4
#    (per_page*3).times {|i| create_track("track_#{i}", @community) }
#
#    tracks = 3.times.flat_map do |i|
#      get community_track_plugin_public_path(action: :view_tracks), params: {:id => @block.id, :page => i+1, :per_page => per_page}, xhr: true
#      assigns[:tracks].all
#    end
#    tracks.map do |t|
#	    puts t.id.inspect
#    end
#    assert_equal tracks.count, tracks.uniq.count
#  end

end
