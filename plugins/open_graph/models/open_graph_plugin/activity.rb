# This is a log of activities, unlike ActivityTrack that is a configuration
class OpenGraphPlugin::Activity < OpenGraphPlugin::Track

  # subclass this to define (e.g. FbAppPlugin::Activity)
  def scrape
  end

end
