class ProfileListBlock < Block

  settings_items :limit, :type => :integer, :default => 6
  settings_items :prioritize_profiles_with_image, :type => :boolean, :default => false

  def self.description
    _('Random profiles')
  end

  # override in subclasses!
  def profiles
    owner.profiles
  end

  def profile_list
    profiles.visible.all(:include => :image, :limit => limit, :select => 'DISTINCT profiles.*, ' + image_prioritizer + randomizer, :order => image_prioritizer + randomizer)
  end

  def profile_count
    profiles.visible.count('DISTINCT(profiles.id)')
  end

  def randomizer
    @randomizer ||= "(profiles.id % #{rand(profile_count) + 1})"
  end

  def image_prioritizer
    prioritize_profiles_with_image ? '(images.id is null),' : ''
  end

  # the title of the block. Probably will be overriden in subclasses.
  def default_title
    _('{#} People or Groups')
  end

  def help
    _('Clicking on the people or groups will take you to their home page.')
  end

  def content
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
