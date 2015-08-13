class OpenGraphPlugin::ActivityTrackConfig < OpenGraphPlugin::TrackConfig

  # workaround for STI bug
  self.table_name = :open_graph_plugin_tracks

  self.track_name = :activity

  Objects = OpenGraphPlugin::Stories::TrackConfigStories[self.name].map do |story, data|
    data[:object_type].to_s
  end.uniq

  def self.objects
    Objects
  end

  validates_uniqueness_of :object_type, scope: [:tracker_id]
  validates_inclusion_of :object_type, in: self.objects

  protected

end

