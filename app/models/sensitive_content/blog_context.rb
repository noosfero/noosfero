class BlogContext < GenericContext

  def content_options
    [
        TextArticle,
        Event,
        RssFeed
    ]
  end

  private

  def sensitive_directory_in_user_profile
    current_user.blogs.first
  end

end
