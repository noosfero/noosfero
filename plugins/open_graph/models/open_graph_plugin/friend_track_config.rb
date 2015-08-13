class OpenGraphPlugin::FriendTrackConfig < OpenGraphPlugin::TrackConfig

  # workaround for STI bug
  self.table_name = :open_graph_plugin_tracks

  self.track_name = :friend

end
