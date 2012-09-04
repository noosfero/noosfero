class ProfileListBlock < Block

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
    visible_profiles = profiles.visible.includes([:image,:domains,:preferred_domain,:environment])
    if !prioritize_profiles_with_image
      result = visible_profiles.all(:limit => limit, :order => 'updated_at DESC').sort_by{ rand }
    elsif visible_profiles.with_image.count >= limit
      result = visible_profiles.with_image.all(:limit => limit * 5, :order => 'updated_at DESC').sort_by{ rand }
    else
      result = visible_profiles.with_image.sort_by{ rand } + visible_profiles.without_image.all(:limit => limit * 5, :order => 'updated_at DESC').sort_by{ rand }
    end
    result.slice(0..limit-1)
  end

  def profile_count
    profiles.visible.count
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
    lambda do
      count=0
      list = profiles.map {|item|
               count+=1
               send(:profile_image_link, item, :minor )
             }.join("\n  ")
      if list.empty?
        list = '<div class="common-profile-list-block-none">'+ _('None') +'</div>'
      else
        list = content_tag 'ul', nl +'  '+ list + nl
      end
      block_title(title) + nl +
      '<div class="common-profile-list-block">' +
      nl + list + nl + '<br style="clear:both" /></div>'
    end
  end

  def view_title
    title.gsub('{#}', profile_count.to_s)
  end

end
