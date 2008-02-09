class ProfileListBlock < Block

  settings_items :limit, :default => 10

  def self.description
    _('A block that displays random profiles')
  end

  def content
    profiles = self.profiles
    lambda do
      profiles.map {|item| profile_image_link(item) }
    end
  end

end
