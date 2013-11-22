require File.dirname(__FILE__) + '/../../test_helper'

class TrackListBlockTest < ActiveSupport::TestCase

  def setup
    @community = fast_create(Community)
    @track = CommunityTrackPlugin::Track.create!(:abstract => 'abstract', :body => 'body', :name => 'track', :profile => @community)

    box = fast_create(Box, :owner_id => @community.id, :owner_type => @community.class.name)
    @block = CommunityTrackPlugin::TrackListBlock.create!(:box => box)
  end

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
    article = fast_create(Article, :profile_id => @community.id)
    assert_includes @community.articles, article
    assert_equal [@track], @block.tracks
  end

  should 'list of articles be limited by block configuration' do
    (@block.limit + 1).times do |i|
      track = CommunityTrackPlugin::Track.create!(:abstract => 'abstract', :body => 'body', :name => "track#{i}", :profile => @community)
    end
    assert_equal @block.limit, @block.tracks.count
  end

  should 'return more link if has more tracks to show' do
    @block.limit.times do |i|
      track = CommunityTrackPlugin::Track.create!(:abstract => 'abstract', :body => 'body', :name => "track#{i}", :profile => @community)
    end
    assert @block.footer
  end

  should 'do not return more link if there is no more tracks to show' do
    (@block.limit-1).times do |i|
      track = CommunityTrackPlugin::Track.create!(:abstract => 'abstract', :body => 'body', :name => "track#{i}", :profile => @community)
    end
    assert !@block.footer
  end

  should 'count all tracks' do
    @block.owner.articles.destroy_all
    tracks_to_insert = @block.limit + 1
    tracks_to_insert.times do |i|
      track = CommunityTrackPlugin::Track.create!(:abstract => 'abstract', :body => 'body', :name => "track#{i}", :profile => @community)
    end
    article = fast_create(Article, :profile_id => @block.owner.id)
    @block.reload
    assert_includes @block.owner.articles, article
    assert_equal tracks_to_insert, @block.count_tracks
  end

  should 'have a second page if there is more tracks than limit' do
    @block.owner.articles.destroy_all
    (@block.limit+1).times do |i|
      track = CommunityTrackPlugin::Track.create!(:abstract => 'abstract', :body => 'body', :name => "track#{i}", :profile => @community)
    end
    assert @block.has_page?(2)
    assert !@block.has_page?(3)
  end

  should 'filter tracks by category' do
    @block.owner.articles.destroy_all
    category = fast_create(Category)
    category2 = fast_create(Category)
    track1 = CommunityTrackPlugin::Track.create!(:abstract => 'abstract', :body => 'body', :name => 'track1', :profile => @community)
    track2 = CommunityTrackPlugin::Track.create!(:abstract => 'abstract', :body => 'body', :name => 'track2', :profile => @community)
    track3 = CommunityTrackPlugin::Track.create!(:abstract => 'abstract', :body => 'body', :name => 'track3', :profile => @community)
    track1.add_category(category)
    @block.category_ids = [category.id]
    assert_equal [track1], @block.all_tracks
  end

  should 'return all tracks if block does not filter by category' do
    @block.owner.articles.destroy_all
    category = fast_create(Category)
    track1 = CommunityTrackPlugin::Track.create!(:abstract => 'abstract', :body => 'body', :name => 'track1', :profile => @community)
    track2 = CommunityTrackPlugin::Track.create!(:abstract => 'abstract', :body => 'body', :name => 'track2', :profile => @community)
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

end
