class GoogleMaps

  def self.initial_zoom
    NOOSFERO_CONF['googlemaps_initial_zoom'] || 4
  end

end
