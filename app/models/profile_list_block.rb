class ProfileListBlock < Block

  settings_items :limit, :default => 6

  def self.description
    _('A block that displays random profiles')
  end

  def profiles
    top = Profile.count

    result = []
    maxsize = [limit,top].compact.min

    maxsize.times do
      profile = Profile.find(random(top) + 1)
      result << profile
    end
        
    result
  end

  def random(top)
    Kernel.rand(top)
  end

  def content
    profiles = self.profiles
    lambda do
      block_title(_('People')) +
      profiles.map {|item| content_tag('div', profile_image_link(item)) }.join("\n")
    end
  end

end
