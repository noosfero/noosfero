class GalleryContext < GenericContext

  def content_options
    [
        UploadedFile
    ]
  end

  private

  def sensitive_directory_in_profile
    current_user.galleries.first
  end

end
