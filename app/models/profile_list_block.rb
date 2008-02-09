class ProfileListBlock < Block

  settings_items :limit, :default => 6

  def self.description
    _('A block that displays random profiles')
  end

  def profiles
    # FIXME pick random people instead
    Profile.find(:all, :limit => self.limit, :order => 'created_at desc')
  end

  def random(top)
    Kernel.rand(top)
  end

  def content
    profiles = self.profiles
    lambda do
      block_title(_('People and Groups')) +
      profiles.map {|item| content_tag('div', profile_image_link(item)) }.join("\n")
    end
  end

end
