class OpenGraphPlugin::TrackConfig < OpenGraphPlugin::Track

  Types = {
    activity: 'ActivityTrackConfig',
    enterprise: 'EnterpriseTrackConfig',
    community: 'CommunityTrackConfig',
    # TODO: not yet implemented
    #friend: 'FriendTrackConfig',
  }

  # define on subclasses (required)
  class_attribute :track_name
  def self.track_enabled_field
    "#{self.track_name}_track_enabled"
  end

  # true if do not depend on records (e.g. EnterpriseTrackConfig depends on friends)
  # redefine on subclasses
  class_attribute :static_trackers
  self.static_trackers = false

  def self.enabled? context, actor
    settings = actor.send "#{context}_settings"
    settings.send "#{self.track_name}_track_enabled"
  end

  scope :tracks_to_profile, lambda { |profile, exclude_actor=nil|
    scope = where object_data_id: profile.id, object_data_type: profile.class.base_class
    scope = scope.where context: OpenGraphPlugin.context
    scope = scope.includes :tracker
    scope = scope.where ['tracker_id <> ?', exclude_actor.id] if exclude_actor
    scope
  }

  # redefine on subclasses
  def self.trackers_to_profile profile
    tracks = self.tracks_to_profile profile
    tracks = tracks.where type: self
    tracks.map(&:tracker)
  end

  def self.profile_tracks profile
    profile.send self.association
  end
  def self.profile_track_objects profile
    self.profile_tracks(profile).map(&:object_data).compact
  end

end
