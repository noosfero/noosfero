require_dependency File.dirname(__FILE__) + '/display_content_block'

class DisplayContentPlugin < Noosfero::Plugin

  def self.plugin_name
    "Display Content Plugin"
  end

  def self.plugin_description
    _("A plugin that adds a block where you could choose any of your content and display it.")
  end

  def self.extra_blocks
    {
      DisplayContentBlock => {}
    }
  end

  def self.has_admin_url?
    false
  end

  def stylesheet?
    true
  end

  def js_files
    ['/javascripts/jstree/_lib/jquery-1.8.3.js', '/javascripts/jstree/jquery.jstree.js']
  end

end
