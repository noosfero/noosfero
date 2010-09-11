# Article type that handles uploaded files.
#
# Limitation: only file metadata are versioned. Only the latest version
# of the file itself is kept. (FIXME?)
class UploadedFile < Article

  track_actions :upload_image, :after_create, :keep_params => ["view_url", "thumbnail_path", "parent.url", "parent.name"], :if => Proc.new { |a| a.published? && a.image? && !a.parent.nil? && a.parent.display_as_gallery? }

  include ShortFilename

  settings_items :title, :type => 'string'
  def title_with_default
    title_without_default || short_filename(name, 60)
  end
  alias_method_chain :title, :default

  validates_size_of :title, :maximum => 60, :if => (lambda { |file| !file.title.blank? })

  def thumbnail_path
    self.image? ? self.full_filename(:thumb).gsub(File.join(RAILS_ROOT, 'public'), '') : nil
  end

  def display_title
    title.blank? ? name : title
  end

  def self.max_size
    UploadedFile.attachment_options[:max_size]
  end

  # FIXME need to define min/max file size
  #
  # default max_size is 1.megabyte to redefine it set options:
  #  :min_size => 2.megabytes
  #  :max_size => 5.megabytes
  has_attachment :storage => :file_system,
    :thumbnails => { :icon => [24,24], :thumb => '130x130>', :slideshow => '320x240>', :display => '640X480>' },
    :thumbnail_class => Thumbnail,
    :max_size => 5.megabytes # remember to update validate message below

  validates_attachment :size => N_("%{fn} of uploaded file was larger than the maximum size of 5.0 MB")

  delay_attachment_fu_thumbnails

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

  def to_html(options = {})
    article = self
    if image?
      lambda do
        if article.display_as_gallery? && options[:gallery_view]
          images = article.parent.images
          current_index = images.index(article)
          total_of_images = images.count

          link_to_previous = if current_index >= 1
            link_to(_('&laquo; Previous'), images[current_index - 1].view_url, :class => 'left')
          else
            content_tag('span', _('&laquo; Previous'), :class => 'left')
          end

          link_to_next = if current_index < total_of_images - 1
            link_to(_('Next &raquo;'), images[current_index + 1].view_url, :class => 'right')
          else
            content_tag('span', _('Next &raquo;'), :class => 'right')
          end

          content_tag(
            'div',
            link_to_previous + content_tag('span', _('image %d of %d'), :class => 'total-of-images') % [current_index + 1, total_of_images] + link_to_next,
            :class => 'gallery-navigation'
          )
        end.to_s +
        image_tag(article.public_filename(:display), :class => article.css_class_name, :style => 'max-width: 100%') +
          content_tag('p', article.abstract, :class => 'uploaded-file-description')

      end
    else
      lambda do
        content_tag('ul', content_tag('li', link_to(article.name, article.url, :class => article.css_class_name))) +
          content_tag('p', article.abstract, :class => 'uploaded-file-description')
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
