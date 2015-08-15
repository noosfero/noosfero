module SiteTourPlugin::SiteTourHelper

  def parse_tour_description(description)
    p = profile rescue nil
    if !p.nil? && description.present?
      description.gsub('{profile.identifier}', p.identifier).
        gsub('{profile.name}', p.name).
        gsub('{profile.url}', url_for(p.url))
    else
      description
    end
  end

end
