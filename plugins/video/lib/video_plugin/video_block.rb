class VideoPlugin::VideoBlock < Block

  attr_accessible :url, :width, :height

  settings_items :url, :type => :string, :default => ""
  settings_items :width, :type => :integer, :default => 400
  settings_items :height, :type => :integer, :default => 315

  YOUTUBE_ID_FORMAT = '\w-'

  def is_youtube?
    VideoPlugin::Video.is_youtube?(url)
  end

  def is_vimeo?
    VideoPlugin::Video.is_vimeo?(url)
  end

  def is_video_file?
    url.match(/.*(mp4|ogg|ogv|webm)$/) ? true : false
  end

  def format_embed_video_url_for_youtube
    VideoPlugin::Video.format_embed_video_url_for_youtube(url)
  end

  def format_embed_video_url_for_vimeo
    VideoPlugin::Video.format_embed_video_url_for_vimeo(url)
  end

  def self.description
    _('Display a Video')
  end

  def help
    _('This block presents a video from youtube, vimeo and some video formats (mp4, ogg, ogv and webm)')
  end

  def api_content(params = {})
    content = {:url => self.url}
    content[:mime_type] = VideoPlugin::Video.mime_type(self.url) if VideoPlugin::Video.is_video_file?(self.url)
    if is_youtube?
      content[:video_type] = 'youtube' 
      content[:url_formatted] = format_embed_video_url_for_youtube
    elsif is_vimeo?
      content[:video_type] = "vimeo"
      content[:url_formatted] = format_embed_video_url_for_vimeo
    else is_video_file?
      content[:video_type] = "video"
      content[:url_formatted] = self.url
    end
    content
  end

  def display_api_content_by_default?
    true
  end

  private

  def extract_youtube_id
    VideoPlugin::Video.extract_youtube_id(url)
  end

  def extract_vimeo_id
    VideoPlugin::Video.extract_vimeo_id(url)
  end

end
