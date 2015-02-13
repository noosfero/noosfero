class ProfileDescriptionBlockPlugin < Noosfero::Plugin

  def self.plugin_name
    # FIXME
    "Profile Description Block"
  end

  def self.extra_blocks
    {
      ProfileDescriptionBlock  => { :type => [Community, Person] }
    }
  end


  def self.plugin_description
    # FIXME
    _("A plugin that adds a block that show the profile description")
  end

  def stylesheet?
    true
  end

end
