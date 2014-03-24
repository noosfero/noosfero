class RelevantContentPlugin < Noosfero::Plugin

  def self.plugin_name
      "Relevant Content Plugin"
  end

  def self.plugin_description
    _("A plugin that lists the most accessed, most commented, most liked and most disliked contents.")
  end

  def self.extra_blocks
    {
     RelevantContentPlugin::RelevantContentBlock => {}
    }
  end

  def stylesheet?
    true
  end

end
