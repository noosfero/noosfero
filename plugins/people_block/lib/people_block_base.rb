class PeopleBlockBase < Block
  settings_items :prioritize_profiles_with_image, :type => :boolean, :default => true
  settings_items :limit, :type => :integer, :default => 6
  settings_items :name, :type => String, :default => ""
  settings_items :address, :type => String, :default => ""
  attr_accessible :name, :address, :prioritize_profiles_with_image

  def self.description
    _('Random people')
  end

  def help
    c_('Clicking on the people or groups will take you to their home page.')
  end

  def default_title
    _('{#} People')
  end

  def view_title
    title.gsub('{#}', profile_count.to_s)
  end

  def profiles
    owner.profiles
  end

  def profile_list
    result = nil
    visible_profiles = profiles.visible.includes([:image,:domains,:preferred_domain,:environment])
    if !prioritize_profiles_with_image
      result = visible_profiles.limit(limit).order('profiles.updated_at DESC').sort_by{ rand }
    elsif profiles.visible.with_image.count >= limit
      result = visible_profiles.with_image.limit(limit * 5).order('profiles.updated_at DESC').sort_by{ rand }
    else
      result = visible_profiles.with_image.sort_by{ rand } + visible_profiles.without_image.limit(limit * 5).order('profiles.updated_at DESC').sort_by{ rand }
    end
    result.slice(0..limit-1)
  end

  def profile_count
    profiles.visible.count
  end

  def extra_option
    { }
  end

end
