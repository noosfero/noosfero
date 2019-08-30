class BlogContext < GenericContext
  def content_types
    [
      TextArticle,
      Event,
      RssFeed
    ]
  end

  private

    def sensitive_directory_in_profile
      selected_profile.blogs.first
    end
end
