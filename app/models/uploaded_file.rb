# Article type that handles uploaded files.
#
# Limitation: only file metadata are versioned. Only the latest version
# of the file itself is kept. (FIXME?)
class UploadedFile < Article

  def self.max_size
    UploadedFile.attachment_options[:max_size]
  end

  # FIXME need to define min/max file size
  #
  # default max_size is 1.megabyte to redefine it set options:
  #  :min_size => 2.megabytes
  #  :max_size => 5.megabytes
  has_attachment :storage => :file_system,
    :thumbnails => { :icon => [24,24], :thumb => '130x130>', :display => '640X480>' },
    :thumbnail_class => Thumbnail,
    :max_size => 5.megabytes # remember to update validate message below

  validates_attachment :size => N_("%{fn} of uploaded file was larger than the maximum size of 5.0 MB")

  def icon_name
    self.image? ? public_filename(:icon) : self.content_type.gsub('/', '-')
  end
  
  def mime_type
    content_type
  end

  def self.short_description
    _("Uploaded file")
  end

  def self.description
    _('Upload any kind of file you want.')
  end

  alias :orig_set_filename :filename=
  def filename=(value)
    orig_set_filename(value)
    self.name = self.filename
  end

  def data
    File.read(self.full_filename)
  end

  # FIXME isn't this too much including just to be able to generate some HTML?
  include ActionView::Helpers::TagHelper

  def to_html(options = {})
    if image?
      tag('img', :src => public_filename(:display), :class => css_class_name, :style => 'max-width: 100%')
    else
      article = self
      lambda do
        content_tag('ul', content_tag('li', link_to(article.name, article.url, :class => article.css_class_name)))
      end
    end
  end

  def allow_children?
    false
  end

  def can_display_hits?
    false
  end

  def display_as_gallery?
    self.parent && self.parent.folder? && self.parent.display_as_gallery?
  end
end
