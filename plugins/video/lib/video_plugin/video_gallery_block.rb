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

  def list_my_galleries
    Article.owner_video_galleries(owner)
  end

end
