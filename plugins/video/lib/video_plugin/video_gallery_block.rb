class VideoPlugin::VideoGalleryBlock < Block

  settings_items :video_gallery_id, :type => :integer
  attr_accessible :video_gallery_id

  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  def self.description
    _('Display a Video Gallery')
  end

  def help
    _('This block presents a video gallery')
  end

  def content(args={})
    block = self
    if video_gallery_id.present?
      video_gallery = VideoPlugin::VideoGallery.find(video_gallery_id)
      proc do
        render :partial => 'content_viewer/video_plugin/video_gallery', :locals => {:video_gallery => video_gallery}
      end
    end
  end

  def list_my_galleries
    Article.owner_video_galleries(owner)
  end

end
