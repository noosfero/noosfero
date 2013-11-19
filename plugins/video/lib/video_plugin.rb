require_dependency File.dirname(__FILE__) + '/video_block'

class VideoPlugin < Noosfero::Plugin

  def self.plugin_name
    "Video Block Plugin"
  end

  def self.plugin_description
    _("A plugin that adds a block where you could add videos from youtube, vimeo and html5.")
  end

  def self.extra_blocks
    {
      VideoBlock => {}
    }
  end

end
