class ProfileInfoBlock < Block

  def self.description
    _('Display profile image and links to access initial homepage, control panel and profile activities.')
  end

  def self.short_description
    _('Show profile information')
  end

  def self.pretty_name
    _('Profile Information')
  end

  def help
    _('Basic information about <i>%{user}</i>: how long <i>%{user}</i> is part of <i>%{env}</i> and useful links.') % { :user => self.owner.name(), :env => self.owner.environment.name() }
  end

  def content(args={})
    block = self
    lambda do |_|
      render :file => 'blocks/profile_info', :locals => { :block => block }
    end
  end

  def cacheable?
    false
  end

end
