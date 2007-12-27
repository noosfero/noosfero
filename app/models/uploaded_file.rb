class UploadedFile < Article

  # FIXME need to define min/max file size
  has_attachment :thumbnails => { :icon => [24,24] }

  def icon_name
    self.image? ? public_filename(:icon) : self.content_type.gsub('/', '-')
  end
  
  def mime_type
    content_type
  end

end
