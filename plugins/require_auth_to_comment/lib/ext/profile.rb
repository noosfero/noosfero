require_dependency 'profile'

class Profile
  settings_items :allow_unauthenticated_comments, :type => :boolean
  attr_accessible :allow_unauthenticated_comments

  descendants.each do |descendant|
    descendant.attr_accessible :allow_unauthenticated_comments
  end
end
