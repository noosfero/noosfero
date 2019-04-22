class ForumContext < GenericContext

  def content_types
    [
        TextArticle,
        Event,
        UploadedFile
    ]
  end

  private

  def sensitive_directory_in_profile
    selected_profile.forums.first
  end

end
