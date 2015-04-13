require_dependency 'profile'

class Profile
  settings_items :google_analytics_profile_id
  attr_accessible :google_analytics_profile_id

  descendants.each do |descendant|
    descendant.attr_accessible :google_analytics_profile_id
  end
end
