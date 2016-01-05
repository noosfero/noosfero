class VideoPlugin::VideoGallery < Folder

  def self.type_name
    _('Video Gallery')
  end

  settings_items :thumbnail_width, :type => :integer, :default => 50
  settings_items :thumbnail_height, :type => :integer, :default => 50
  settings_items :videos_per_row, :type => :integer, :default => 5

  validate :not_belong_to_blog

  def not_belong_to_blog
    errors.add(:parent, "A video gallery should not belong to a blog.") if parent && parent.blog?
  end

  acts_as_having_settings :field => :setting

  xss_terminate :only => [ :body ], :with => 'white_list', :on => 'validation'

  include WhiteListFilter
  filter_iframes :body
  def iframe_whitelist
    profile && profile.environment && profile.environment.trusted_sites_for_iframe
  end

  def self.short_description
    _('Video Gallery')
  end

  def self.description
    _('A gallery of link to videos that are hosted elsewhere.')
  end

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    video_gallery = self
    proc do
      render :partial => 'content_viewer/video_plugin/video_gallery', :locals => {:video_gallery => video_gallery}
    end
  end

  def video_gallery?
    true
  end

  def can_display_hits?
    false
  end

  def accept_comments?
    false
  end

  def self.icon_name(article = nil)
    'Video gallery'
  end

  def news(limit = 30, highlight = false)
    profile.recent_documents(limit, ["articles.type != ? AND articles.highlighted = ? AND articles.parent_id = ?", 'Folder', highlight, id])
  end

end
