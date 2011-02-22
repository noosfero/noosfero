class HomeController < PublicController

  def index
    @has_news = false
    if environment.enabled?('use_portal_community') && environment.portal_community
      @has_news = true
      @news_cache_key = environment.portal_news_cache_key
      if !read_fragment(@news_cache_key)
        portal_community = environment.portal_community
        @highlighted_news = portal_community.news(2, true)
        @portal_news = portal_community.news(7, true) - @highlighted_news
        @area_news = environment.portal_folders
      end
    end
  end

end
