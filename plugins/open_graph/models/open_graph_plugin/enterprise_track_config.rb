class OpenGraphPlugin::EnterpriseTrackConfig < OpenGraphPlugin::TrackConfig

  # workaround for STI bug
  self.table_name = :open_graph_plugin_tracks

  self.track_name = :enterprise

  self.static_trackers = true

  def self.trackers_to_profile enterprise
    trackers = enterprise.members.to_set
    trackers.merge enterprise.fans if enterprise.respond_to? :fans
    trackers.to_a
  end

  def self.profile_track_objects profile
    (profile.enterprises.is_public.enabled + profile.favorite_enterprises.is_public.enabled).uniq
  end

end
