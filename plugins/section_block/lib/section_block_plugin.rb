class SectionBlockPlugin < Noosfero::Plugin

  def self.plugin_name
    "Section Block Plugin"
  end

  def self.plugin_description
    _("A plugin that add a Section block.")
  end

  def self.extra_blocks
    { SectionBlockPlugin::SectionBlock => {} }
  end

  def stylesheet?
    true
  end

end
