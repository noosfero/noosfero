class HomeController < PublicController

  before_filter :require_admin, only: :reorder

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
    @person_template = user && user.template || params[:template_id] && Person.find(params[:template_id])
  end

  def reorder
    if params[:article_id].nil? || !params[:direction].in?(['up', 'down'])
      head :bad_request
      return
    end

    article = environment.portal_community.articles.find(params[:article_id])

    case params[:direction]
    when 'up'
      move_article_up(article)
    when 'down'
      move_article_down(article)
    end

    redirect_to action: :index
  end

  private

  def move_article_up(article)
    article.move_lower
  end

  def move_article_down(article)
    article.move_higher
  end

  def require_admin
    head :forbidden unless environment.admins.include? current_person
  end
end
