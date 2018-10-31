class ForumContext < GenericContext

  def content_options
    [
        TextArticle,
        Event,
        UploadedFile
    ]
  end

  private

  def directory_in_user_profile
    current_user.forums.first
  end

end
