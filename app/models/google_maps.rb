class GoogleMaps

  def self.initial_zoom
    NOOSFERO_CONF['googlemaps_initial_zoom'] || 4
  end

  def self.api_key
    NOOSFERO_CONF['googlemaps_api_key']
  end

end
