class GalleryContext < GenericContext

  def content_options
    [
        UploadedFile
    ]
  end

  private

  def sensitive_directory_in_profile
    selected_profile.galleries.first
  end

end
