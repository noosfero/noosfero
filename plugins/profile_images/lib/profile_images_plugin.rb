class ProfileImagesPlugin < Noosfero::Plugin
  def self.plugin_name
    'ProfileImagesPlugin'
  end

  def self.plugin_description
    _('Adds a block that lists all images inside a profile.')
  end

  def self.extra_blocks
    {
      ProfileImagesPlugin::ProfileImagesBlock => { type: [Person, Community, Enterprise] }
    }
  end

  def self.has_admin_url?
    false
  end

  def stylesheet?
    true
  end
end
