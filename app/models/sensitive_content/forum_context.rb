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
    current_user.forums.first
  end

end
