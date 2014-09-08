module CommunityTrackPlugin::TrackHelper

  include CategoriesHelper

  def category_class(track)
    'category_' + (track.categories.empty? ? 'not_defined' : track.categories.first.name.to_slug)
  end

  def track_card_lead(track)
    lead_stripped = strip_tags(track.lead)
    excerpt(lead_stripped, lead_stripped.first(3), track.image ? 180 : 300)
  end

  def track_color_style(track)
    category_color_style(track.categories.first.with_color) if !track.categories.empty?
  end

  def track_name_color_style(track)
    category = track.categories.empty? ? nil : track.categories.first.with_color
    category ? "color: ##{category.display_color};" : ''
  end

end
