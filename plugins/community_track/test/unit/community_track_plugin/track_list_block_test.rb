require File.dirname(__FILE__) + '/../../test_helper'

class TrackListBlockTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @track = create_track('track', profile)
    box = fast_create(Box, :owner_id => @profile.id, :owner_type => @profile.class.name)
    @block = create(CommunityTrackPlugin::TrackListBlock, :box => box)
  end

  attr_reader :profile

  should 'describe yourself' do
    assert CommunityTrackPlugin::TrackListBlock.description
  end

  should 'return track as track partial' do
    assert_equal 'track', @block.track_partial
  end

  should 'load more at another page default to false' do
    assert !@block.more_another_page
  end

  should 'list articles only of track type' do
    article = fast_create(Article, :profile_id => profile.id)
    assert_includes profile.articles, article
    assert_equal [@track], @block.tracks
  end

  should 'list of articles be limited by block configuration' do
    (@block.limit + 1).times { |i| create_track("track#{i}", profile) }
    assert_equal @block.limit, @block.tracks.size
  end

  should 'return more link if has more tracks to show' do
    @block.limit.times { |i| create_track("track#{i}", profile) }
    assert @block.footer
  end

  should 'do not return more link if there is no more tracks to show' do
    (@block.limit-1).times { |i| create_track("track#{i}", profile) }
    assert !@block.footer
  end

  should 'count all tracks' do
    @block.owner.articles.destroy_all
    tracks_to_insert = @block.limit + 1
    tracks_to_insert.times { |i| create_track("track#{i}", profile) }
    article = fast_create(Article, :profile_id => @block.owner.id)
    @block.reload
    assert_includes @block.owner.articles, article
    assert_equal tracks_to_insert, @block.count_tracks
  end

  should 'have a second page if there is more tracks than limit' do
    @block.owner.articles.destroy_all
    (@block.limit+1).times { |i| create_track("track#{i}", profile) }
    assert @block.has_page?(2)
    assert !@block.has_page?(3)
  end

  should 'filter tracks by category' do
    @block.owner.articles.destroy_all
    category = fast_create(Category)
    category2 = fast_create(Category)
    track1 = create_track("track1", profile)
    track2 = create_track("track2", profile)
    track3 = create_track("track3", profile)
    track1.add_category(category)
    @block.category_ids = [category.id]
    assert_equal [track1], @block.all_tracks
  end

  should 'return all tracks if block does not filter by category' do
    @block.owner.articles.destroy_all
    category = fast_create(Category)
    track1 = create_track("track1", profile)
    track2 = create_track("track2", profile)
    track1.add_category(category)
    assert_includes @block.all_tracks, track1
    assert_includes @block.all_tracks, track2
  end

  should 'accept any categories' do
    assert @block.accept_category?(nil)
    assert @block.accept_category?(fast_create(Category))
  end

  should 'format category ids array avoiding duplicates and zeros' do
    @block.category_ids = ["0", "0", "1", "1", "2", nil]
    assert_equal [1, 2], @block.category_ids
  end

  should 'define expiration condition' do
    condition = CommunityTrackPlugin::TrackListBlock.expire_on
    assert !condition[:profile].empty?
    assert !condition[:environment].empty?
  end

  should 'return track list block categories' do
    category1 = fast_create(Category)
    category2 = fast_create(Category)
    @block.category_ids = [category1.id, category2.id]
    assert_equivalent [category1, category2], @block.categories
  end

  should 'return nothing if track list block has no categories' do
    @block.category_ids = []
    assert_equivalent [], @block.categories
  end

end
