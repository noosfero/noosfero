class ProfileListBlock < Block

  attr_accessible :prioritize_profiles_with_image, :kind_filter

  settings_items :limit, :type => :integer, :default => 6
  settings_items :prioritize_profiles_with_image, :type => :boolean, :default => true
  settings_items :kind_filter, :type => :string

  def self.description
    _('Random profiles')
  end

  # override in subclasses!
  def base_profiles
    owner.profiles
  end

  def profiles(user=nil)
    filtered_profiles = base_profiles.visible.no_templates.accessible_to(user)
    filtered_profiles = filtered_profiles.with_kind(kind) if kind.present?
    filtered_profiles
  end

  def profile_list(user=nil)
    result = profiles(user).includes([:image,:domains,:preferred_domain,:environment])
    if !prioritize_profiles_with_image
      result = result.limit(get_limit).order('profiles.updated_at DESC').sort_by{ rand }
    elsif result.with_image.count >= get_limit
      result = result.with_image.limit(get_limit * 5).order('profiles.updated_at DESC').sort_by{ rand }
    else
      result = result.with_image.sort_by{ rand } + result.without_image.limit(get_limit * 5).order('profiles.updated_at DESC').sort_by{ rand }
    end
    result.slice(0..get_limit-1)
  end

  def profile_count(user=nil)
    profiles(user).count
  end

  # the title of the block. Probably will be overridden in subclasses.
  def default_title
    _('{#} People or Groups')
  end

  def help
    _('Clicking on the people or groups will take you to their home page.')
  end

  def view_title(user=nil)
    title.gsub('{#}', profile_count(user).to_s)
  end

  # override in subclasses! See MembersBlock for example
  def extra_option
    {}
  end

  def available_kinds
    kinds = environment.kinds.where(:type => base_class.try(:name)).order(:name)
    [[_('All kinds'), nil]] + kinds.map{ |k| [k.name, k.id] }
  end

  def kind
    Kind.find_by(id: self.kind_filter)
  end

  private

  def base_class
    nil
  end
end
