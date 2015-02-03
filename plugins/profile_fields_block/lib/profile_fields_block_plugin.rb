class ProfileFieldsBlockPlugin < Noosfero::Plugin

  def self.plugin_name
    # FIXME
    "ProfileFieldsBlockPlugin"
  end

  def self.extra_blocks
    {
      ProfileFieldsBlock  => { :type => [Community] }
    }
  end


  def self.plugin_description
    # FIXME
    _("A plugin that include a generic block")
  end

  def stylesheet?
    true
  end

end
