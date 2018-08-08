class PeopleBlockBase < ProfileListBlock
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

  def view_title(user=nil)
    title.gsub('{#}', profile_count.to_s)
  end

  def self.profiles
    owner.profiles
  end

  def self.profile_list
    result = nil
    visible_profiles = profiles.visible.activated.includes([:image,:domains,:preferred_domain,:environment])
    if !prioritize_profiles_with_image
      result = visible_profiles.limit(limit).order('profiles.updated_at DESC').sort_by{ rand }
    elsif profiles.visible.with_image.count(:id) >= limit
      result = visible_profiles.with_image.limit(limit * 5).order('profiles.updated_at DESC').sort_by{ rand }
    else
      result = visible_profiles.with_image.sort_by{ rand } + visible_profiles.without_image.limit(limit * 5).order('profiles.updated_at DESC').sort_by{ rand }
    end
    result.slice(0..limit-1)
  end

  def self.profile_count
    profiles.visible.count(:id)
  end
  
  def base_profiles
    owner.people
  end

  def extra_option
    { }
  end

  def api_content(params = {})
    people = profiles(params[:current_person])
    content = {}
    content['people'] = Api::Entities::Person.represent(people.limit(self.limit).sort{|x,y| x.name <=> y.name}).as_json
    content['#'] = people.count
    content
  end

end
