class VideoBlock < Block

  attr_accessible :url, :width, :height
  
  settings_items :url, :type => :string, :default => ""
  settings_items :width, :type => :integer, :default => 400
  settings_items :height, :type => :integer, :default => 315

  YOUTUBE_ID_FORMAT = '\w-'

  def is_youtube?
    url.match(/.*(youtube.com.*v=[#{YOUTUBE_ID_FORMAT}]+|youtu.be\/[#{YOUTUBE_ID_FORMAT}]+).*/) ? true : false
  end

  def is_vimeo?
    url.match(/^(http[s]?:\/\/)?(www.)?(vimeo.com|player.vimeo.com\/video)\/[[:digit:]]+/) ? true : false
  end

  def is_video_file?
    url.match(/.*(mp4|ogg|ogv|webm)$/) ? true : false
  end

  def format_embed_video_url_for_youtube
    "//www.youtube-nocookie.com/embed/#{extract_youtube_id}?rel=0&wmode=transparent" if is_youtube?
  end

  def format_embed_video_url_for_vimeo
    "//player.vimeo.com/video/#{extract_vimeo_id}" if is_vimeo?
  end

  def self.description
    _('Display a Video')
  end

  def help
    _('This block presents a video from youtube, vimeo and some video formats (mp4, ogg, ogv and webm)')
  end

  def content(args={})
    block = self

    proc do
      render :file => 'video_block', :locals => { :block => block }
    end
  end

  private

  def extract_youtube_id
    return nil unless is_youtube?
    youtube_match = url.match("v=([#{YOUTUBE_ID_FORMAT}]*)")
    youtube_match ||= url.match("youtu.be\/([#{YOUTUBE_ID_FORMAT}]*)")
    youtube_match[1] unless youtube_match.nil?
  end

  def extract_vimeo_id
    return nil unless is_vimeo?
    vimeo_match = url.match('([[:digit:]]*)$')
    vimeo_match[1] unless vimeo_match.nil?
  end

end
