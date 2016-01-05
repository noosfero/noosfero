require 'noosfero/translatable_content'
require 'application_helper'
require 'net/http'

class VideoPlugin::Video < Article

  settings_items :video_url,    :type => :string, :default => 'http://'
  settings_items :video_width,  :type => :integer, :default => 499
  settings_items :video_height, :type => :integer, :default => 353
  #Video Providers are: youtube, vimeo, file
  settings_items :video_provider,    :type => :string
  settings_items :video_format,      :type => :string
  settings_items :video_id,          :type => :string
  settings_items :video_thumbnail_url,    :type => :string, :default => '/plugins/video/images/video_generic_thumbnail.jpg'
  settings_items :video_thumbnail_width,  :type=> :integer
  settings_items :video_thumbnail_height, :type=> :integer
  settings_items :video_duration, :type=> :integer, :default => 0

  attr_accessible :video_url

  before_save :fill_video_properties

  def self.type_name
    _('Video')
  end

  def can_display_versions?
    true
  end

  def self.short_description
    _('Embedded Video')
  end

  def self.description
    _('Display embedded videos.')
  end
  
  def is_youtube?
    VideoPlugin::Video.is_youtube?(self.video_url)
  end

  def is_vimeo?
    VideoPlugin::Video.is_vimeo?(self.video_url)
  end  

  include ActionView::Helpers::TagHelper
  def to_html(options={})
    article = self
    proc do
      render :partial => 'content_viewer/video_plugin/video', :locals => {:article => article}
    end
  end

  def fitted_width
    499
  end

  def fitted_height
    ((fitted_width * self.video_height) / self.video_width).to_i
  end

  def thumbnail_fitted_width
    80
  end

  def thumbnail_fitted_height
    ((thumbnail_fitted_width * self.video_thumbnail_height) / self.video_thumbnail_width).to_i
  end

  def no_browser_support_message
    '<p class="vjs-no-js">To view this video please enable JavaScript, and consider upgrading to a web browser that <a href="http://videojs.com/html5-video-support/" target="_blank">supports HTML5 video</a></p>'
  end

  def self.is_youtube?(video_url)
    video_url.match(/.*(youtube.com.*v=[#{YOUTUBE_ID_FORMAT}]+|youtu.be\/[#{YOUTUBE_ID_FORMAT}]+).*/) ? true : false
  end

  def self.is_vimeo?(video_url)
    video_url.match(/^(http[s]?:\/\/)?(www.)?(vimeo.com|player.vimeo.com\/video)\/([A-z]|\/)*[[:digit:]]+/) ? true : false
  end

  def self.is_video_file?(video_url)
    video_url.match(/\.(mp4|ogg|ogv|webm)/) ? true : false
  end

  def self.format_embed_video_url_for_youtube(video_url)
    "//www.youtube-nocookie.com/embed/#{extract_youtube_id(video_url)}?rel=0&wmode=transparent" if is_youtube?(video_url)
  end

  def self.format_embed_video_url_for_vimeo(video_url)
    "//player.vimeo.com/video/#{extract_vimeo_id(video_url)}" if is_vimeo?(video_url)
  end

  def format_embed_video_url_for_youtube
    VideoPlugin::Video.format_embed_video_url_for_youtube(self.video_url)
  end

  def format_embed_video_url_for_vimeo
    VideoPlugin::Video.format_embed_video_url_for_vimeo(self.video_url)
  end

  def self.extract_youtube_id(video_url)
    return nil unless self.is_youtube?(video_url)
    youtube_match = video_url.match("v=([#{YOUTUBE_ID_FORMAT}]*)")
    youtube_match ||= video_url.match("youtu.be\/([#{YOUTUBE_ID_FORMAT}]*)")
    youtube_match[1] unless youtube_match.nil?
  end

  def self.extract_vimeo_id(video_url)
    return nil unless self.is_vimeo?(video_url)
    vimeo_match = video_url.match('([[:digit:]]*)$')
    vimeo_match[1] unless vimeo_match.nil?
  end

  private

  YOUTUBE_ID_FORMAT = '\w-'

  def fill_video_properties
    if is_youtube?
      fill_youtube_video_properties
    elsif is_vimeo?
      fill_vimeo_video_properties
    elsif true
      self.video_format = detect_file_format
      self.video_provider = 'file'
    end
  end

  def fill_youtube_video_properties
    self.video_provider = 'youtube'
    self.video_id = extract_youtube_id
    url = "http://www.youtube.com/oembed?url=http%3A//www.youtube.com/watch?v%3D#{self.video_id}&format=json"
    resp = Net::HTTP.get_response(URI.parse(url))
    buffer = resp.body
    vid = JSON.parse(buffer)
    self.video_thumbnail_url = vid['thumbnail_url']
    self.video_width = vid['width']
    self.video_height = vid['height']
    self.video_thumbnail_width = vid['thumbnail_width']
    self.video_thumbnail_height = vid['thumbnail_height']
  end

  def fill_vimeo_video_properties
    self.video_provider = 'vimeo'
    self.video_id = extract_vimeo_id
    url = "http://vimeo.com/api/v2/video/#{self.video_id}.json"
    resp = Net::HTTP.get_response(URI.parse(url))
    buffer = resp.body
    vid = JSON.parse(buffer)
    vid = vid[0]
    self.video_thumbnail_url = vid['thumbnail_large']
    self.video_width = vid['width']
    self.video_height = vid['height']
    self.video_thumbnail_width = 640
    self.video_thumbnail_height = 360
  end

  def detect_file_format
   video_type = 'video/unknown'
   if /.mp4/i =~ self.video_url or /.mov/i =~ self.video_url
    video_type='video/mp4'
   elsif /.webm/i =~ self.video_url
    video_type='video/webm'
   elsif /.og[vg]/i =~ self.video_url
    video_type='video/ogg'
   end
   video_type
  end

  def extract_youtube_id
    VideoPlugin::Video.extract_youtube_id(self.video_url)
  end

  def extract_vimeo_id
    VideoPlugin::Video.extract_vimeo_id(self.video_url)
  end

end
