# Article type that handles uploaded files.
#
# Limitation: only file metadata are versioned. Only the latest version
# of the file itself is kept. (FIXME?)
class UploadedFile < Article

  # FIXME need to define min/max file size
  #
  # default max_size is 1.megabyte to redefine it set options:
  #  :min_size => 2.megabytes
  #  :max_size => 5.megabytes
  has_attachment :storage => :file_system,
    :thumbnails => { :icon => [24,24] },
    :thumbnail_class => Thumbnail

  def self.max_size
    UploadedFile.attachment_options[:max_size]
  end

  validates_attachment :size => _("The file you uploaded was larger than the maximum size of %s") % UploadedFile.max_size.to_humanreadable

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

  def allow_children?
    false
  end

  def can_display_hits?
    false
  end

end
