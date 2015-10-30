class GalleryBlockPlugin < Noosfero::Plugin
  def self.plugin_name
    'Gallery Block'
  end

  def self.plugin_description
    _('Includes a block to display images from  a gallery.')
  end

  def self.extra_blocks
    {
      GalleryBlock => {:type => [Community, Environment]}
    }
  end

  def stylesheet?
    true
  end

end
