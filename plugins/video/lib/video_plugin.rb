class VideoPlugin < Noosfero::Plugin
  def self.plugin_name
    "Video Content type, Video Block and Video Gallery Plugin"
  end

  def self.plugin_description
    _("A plugin that adds a block where you can add videos from youtube, vimeo and html5.")
  end

  def self.extra_blocks
    { VideoPlugin::VideoBlock => {}, VideoPlugin::VideoGalleryBlock => { position: ["1"] } }
  end

  def stylesheet?
    true
  end

  def content_types
    [VideoPlugin::VideoGallery, VideoPlugin::Video]
  end

  def content_remove_new(content)
    if content.kind_of?(VideoPlugin::VideoGallery) || content.kind_of?(VideoPlugin::Video)
      true
    end
  end

  def content_remove_upload(content)
    if content.kind_of?(VideoPlugin::VideoGallery) || content.kind_of?(VideoPlugin::Video)
      true
    end
  end

  def article_extra_toolbar_buttons(content)
    return [] if !content.kind_of?(VideoPlugin::VideoGallery)

    {
      title: _("New Video"),
      icon: :new,
      url: { action: "new", type: "VideoPlugin::Video", controller: "cms", parent_id: content.id },
      html_options: { id: "new-video-btn" }
    }
  end
end
