class FolderContext < GenericContext

  def content_types
    [
        TextArticle,
        Event,
        UploadedFile,
        Folder
    ]
  end

  private

  def sensitive_directory_in_profile
    selected_profile.folders.select do |folder|
      folder.class == Folder
    end.first
  end

end
