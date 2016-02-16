require 'test_helper'

def create_track(name, profile)
  track = CommunityTrackPlugin::Track.new(:abstract => 'abstract', :body => 'body', :name => name, :profile => profile)
  track.add_category(fast_create(Category))
  track.save!
  track
end
