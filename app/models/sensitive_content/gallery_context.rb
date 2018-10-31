class GalleryContext < GenericContext

  def content_options
    [
        UploadedFile
    ]
  end

  private

  def directory_in_user_profile
    current_user.galleries.first
  end

end
