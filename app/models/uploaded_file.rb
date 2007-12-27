class UploadedFile < Article

  # FIXME need to define min/max file size
  has_attachment :thumbnails => { :icon => [24,24] }

  def icon_name
    public_filename(:icon)
  end

end
