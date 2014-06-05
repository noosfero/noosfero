class ContainerBlockPlugin < Noosfero::Plugin

  def self.plugin_name
    "Container Block Plugin"
  end

  def self.plugin_description
    _("A plugin that add a container block.")
  end

  def self.extra_blocks
    { ContainerBlockPlugin::ContainerBlock => {} }
  end

  def stylesheet?
    true
  end

  def js_files
    'container_block.js'
  end

end
