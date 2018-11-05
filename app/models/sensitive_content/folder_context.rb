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

  def sensitive_directory_in_user_profile
    current_user.folders.first
  end

end
