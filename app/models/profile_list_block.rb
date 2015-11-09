class ProfileListBlock < Block

  attr_accessible :prioritize_profiles_with_image

  settings_items :limit, :type => :integer, :default => 6
  settings_items :prioritize_profiles_with_image, :type => :boolean, :default => true

  def self.description
    _('Random profiles')
  end

  # override in subclasses!
  def profiles
    owner.profiles
  end

  def profile_list
    result = nil
    public_profiles = profiles.is_public.includes([:image,:domains,:preferred_domain,:environment])
    if !prioritize_profiles_with_image
result = public_profiles.all(:limit => get_limit, :order => 'profiles.updated_at DESC').sort_by{ rand }
    elsif profiles.visible.with_image.count >= get_limit
      result = public_profiles.with_image.all(:limit => get_limit * 5, :order => 'profiles.updated_at DESC').sort_by{ rand }
    else
      result = public_profiles.with_image.sort_by{ rand } + public_profiles.without_image.all(:limit => get_limit * 5, :order => 'profiles.updated_at DESC').sort_by{ rand }
    end
    result.slice(0..get_limit-1)
  end

  def profile_count
    profiles.is_public.length
  end

  # the title of the block. Probably will be overriden in subclasses.
  def default_title
    _('{#} People or Groups')
  end

  def help
    _('Clicking on the people or groups will take you to their home page.')
  end

  def content(args={})
    profiles = self.profile_list
    title = self.view_title
    nl = "\n"
    proc do |context|
      count=0
      list = profiles.map {|item|
               count+=1
               send(:profile_image_link, item, :minor )
             }.join("\n  ")
      if list.empty?
        list = content_tag 'div', _('None'), :class => 'common-profile-list-block-none'
      else
        list = content_tag 'ul', nl +'  '+ list + nl
      end
      block_title(title) + nl +
      content_tag('div', nl + list + nl + tag('br', :style => 'clear:both'))
    end
  end

  def view_title
    title.gsub('{#}', profile_count.to_s)
  end

  # override in subclasses! See MembersBlock for example
  def extra_option
    {}
  end
end
