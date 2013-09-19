# Article type that handles uploaded files.
#
# Limitation: only file metadata are versioned. Only the latest version
# of the file itself is kept. (FIXME?)
class UploadedFile < Article

  def self.type_name
    _('File')
  end

  track_actions :upload_image, :after_create, :keep_params => ["view_url", "thumbnail_path", "parent.url", "parent.name"], :if => Proc.new { |a| a.published? && a.image? && !a.parent.nil? && a.parent.gallery? }, :custom_target => :parent

  include ShortFilename

  settings_items :title, :type => 'string'
  xss_terminate :only => [ :title ]

  def title_with_default
    title_without_default || short_filename(name, 60)
  end
  alias_method_chain :title, :default

  validates_size_of :title, :maximum => 60, :if => (lambda { |file| !file.title.blank? })

  sanitize_filename

  before_create do |uploaded_file|
    uploaded_file.is_image = true if uploaded_file.image?
  end

  def thumbnail_path
    self.image? ? self.full_filename(:display).gsub(File.join(RAILS_ROOT, 'public'), '') : nil
  end

  def display_title
    title.blank? ? name : title
  end

  def first_paragraph
    ''
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

  validates_attachment :size => N_("%{fn} of uploaded file was larger than the maximum size of 5.0 MB").fix_i18n

  delay_attachment_fu_thumbnails

  postgresql_attachment_fu

  # Use this method only to get the generic icon for this kind of content.
  # If you want the specific icon for a file type or the iconified version
  # of an image, use FilePresenter.for(uploaded_file).icon_name
  def self.icon_name(article = nil)
    unless article.nil?
      warn = ('='*80) + "\n" +
             'The method `UploadedFile.icon_name(obj)` is deprecated. ' +
             'You must to encapsulate UploadedFile with `FilePresenter.for()`.' +
             "\n" + ('='*80)
      raise NoMethodError, warn if ENV['RAILS_ENV'] == 'test'
      Rails.logger.warn warn if Rails.logger
      puts warn if ENV['RAILS_ENV'] == 'development'
    end
    'upload-file'
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
    warn = ('='*80) + "\n" +
           'The method `UploadedFile#to_html()` is deprecated. ' +
           'You must to encapsulate UploadedFile with `FilePresenter.for()`.' +
           "\n" + ('='*80)
    raise NoMethodError, warn if ENV['RAILS_ENV'] == 'test'
    Rails.logger.warn warn if Rails.logger
    puts warn if ENV['RAILS_ENV'] == 'development'
    article = self
    if image?
      lambda do
        image_tag(article.public_filename(:display),
                  :class => article.css_class_name,
                  :style => 'max-width: 100%') +
        content_tag('div', article.abstract, :class => 'uploaded-file-description')
      end
    else
      lambda do
        content_tag('div',
                    link_to(article.name, article.url),
                    :class => article.css_class_name) +
        content_tag('div', article.abstract, :class => 'uploaded-file-description')
      end
    end
  end

  def extension
    dotindex = self.filename.rindex('.')
    return nil unless dotindex
    self.filename[(dotindex+1)..-1].downcase
  end

  def allow_children?
    false
  end

  def can_display_hits?
    false
  end

  def gallery?
    self.parent && self.parent.folder? && self.parent.gallery?
  end

  def uploaded_file?
    true
  end

end
