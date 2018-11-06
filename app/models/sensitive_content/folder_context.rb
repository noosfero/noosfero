class FolderContext < GenericContext

  def content_options
    [
        TextArticle,
        Event,
        UploadedFile,
        Folder
    ]
  end

  private

  def sensitive_directory_in_profile
    current_user.folders.select do |folder|
      folder.class == Folder
    end.first
  end

end
