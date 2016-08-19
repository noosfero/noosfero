class Html5VideoPlugin::VideoChannel < Folder

  def self.short_description
    _('Video Channel')
  end

  def self.description
    _('A video channel, where you can make your own web TV.')
  end

  include ActionView::Helpers::TagHelper
  def to_html(options={})
    article = self
    lambda do
      render :file => 'content_viewer/video_channel', :locals => {:article => article}
    end
  end

  def video_channel?
    true
  end

  def self.icon_name(article = nil)
    'videochannel'
  end

  def accept_article?
    false
  end
end
