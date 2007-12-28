class UploadedFile < Article

  # FIXME need to define min/max file size
  has_attachment :thumbnails => { :icon => [24,24] }, :storage => :file_system

  validates_as_attachment

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

end
