class GalleryContext < GenericContext
  def content_types
    [
      UploadedFile
    ]
  end

  private

    def sensitive_directory_in_profile
      selected_profile.galleries.first
    end
end
