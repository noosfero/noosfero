class ProfileImageBlock < Block

  settings_items :show_name, :type => :boolean, :default => false

  def self.description
    _('A block that displays only image of profiles')
  end

  def help
    _('This block presents the profile image.')
  end

  def default_title
    owner.name
  end

  def content
    block = self
    s = show_name
    lambda do
      render :file => 'blocks/profile_image', :locals => { :block => block, :show_name => s}
    end
  end

  def editable?
    true
  end

  def cacheable?
    false
  end

end
