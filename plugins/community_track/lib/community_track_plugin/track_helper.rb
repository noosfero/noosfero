module CommunityTrackPlugin::TrackHelper

  def category_class(track)
    'category_' + (track.categories.empty? ? 'not_defined' : track.categories.first.name.to_slug)
  end

  def track_card_lead(track)
    lead_stripped = strip_tags(track.lead)
    excerpt(lead_stripped, lead_stripped.first(3), track.image ? 180 : 300)
  end

end
