class VideoBlock < Block

  settings_items :url, :type => :string, :default => ""
  settings_items :width, :type => :integer, :default => 400
  settings_items :height, :type => :integer, :default => 315

  def is_youtube?
    url.match(/.*(youtube.com.*v=[[:alnum:]]*|youtu.be\/[[:alnum:]]*).*/) ? true : false
  end

  def is_vimeo?
    url.match(/^(http[s]?:\/\/)?(www.)?(vimeo.com|player.vimeo.com\/video)\/[[:digit:]]*/) ? true : false
  end

  def is_video_file? 
    url.match(/.*(mp4|ogg|ogv|webm)$/) ? true : false
  end

  #FIXME Make this test
  def format_embed_video_url_for_youtube
    "//www.youtube-nocookie.com/embed/#{extract_youtube_id}?rel=0&wmode=transparent"
  end

  #FIXME Make this test
  def format_embed_video_url_for_vimeo
    "//player.vimeo.com/video/#{extract_vimeo_id}"
  end

  #FIXME Make this test
  def self.description
    _('Add Video')
  end

  #FIXME Make this test
  def help
    _('This block presents a video block.')
  end

  #FIXME Make this test
  def content(args={})
    block = self

    lambda do
      render :file => 'video_block', :locals => { :block => block }
    end
  end
  
  #FIXME Make this test
  def cacheable?
    false
  end

  private

  #FIXME Make this test
  def extract_youtube_id
    return nil unless is_youtube?
    youtube_match = url.match('v=([[:alnum:]]*)')
    youtube_match ||= url.match('youtu.be\/([[:alnum:]]*)')
    youtube_match[1] unless youtube_match.nil? 
  end
  
  def extract_vimeo_id
    return nil unless is_vimeo?
    vimeo_match = url.match('([[:digit:]]*)$')
    vimeo_match[1] unless vimeo_match.nil? 
  end
end
