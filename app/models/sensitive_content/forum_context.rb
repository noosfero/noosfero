class ForumContext < GenericContext

  def content_options
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
