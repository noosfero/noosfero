class HomeController < PublicController

  def index
    @has_news = false
    if environment.portal_enabled
      @has_news = true
      @news_cache_key = environment.portal_news_cache_key(FastGettext.locale)
      if !read_fragment(@news_cache_key)
        portal_community = environment.portal_community
        @highlighted_news = portal_community.news(environment.highlighted_news_amount, true)
        @portal_news = portal_community.news(environment.portal_news_amount, true).offset(environment.highlighted_news_amount)
        @area_news = environment.portal_folders
      end
    end
  end

  def terms
    @no_design_blocks = true
  end

  def welcome
    @no_design_blocks = true
    @display_confirmation_tips = !user.present? && !environment.enabled?(:skip_new_user_email_confirmation)
    @person_template = user && user.template || params[:template_id] && Person.find(params[:template_id])
  end

end
