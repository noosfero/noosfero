class ProfileImageBlock < Block

  def self.description
    _('A block that displays only image of profiles')
  end

  def help
    _('This block presents the profile image.')
  end

  def content
    block = self
    lambda do
      render :file => 'blocks/profile_image', :locals => { :block => block }
    end
  end

  def editable?
    false
  end

  def cacheable?
    false
  end

end
