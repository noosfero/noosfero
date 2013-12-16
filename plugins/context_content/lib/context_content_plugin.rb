class ContextContentPlugin < Noosfero::Plugin

  def self.plugin_name
    "Display Context Content"
  end

  def self.plugin_description
    _("A plugin that display content based on page context.")
  end

  def self.extra_blocks
    {
      ContextContentPlugin::ContextContentBlock => { :type => [Person, Community, Enterprise] }
    }
  end

  def stylesheet?
    true
  end

end
