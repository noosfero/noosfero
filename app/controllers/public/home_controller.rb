class HomeController < PublicController

  before_action :require_admin, only: :reorder

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
    if params[:index].blank? || !params[:direction].in?(['up', 'down'])
      head :bad_request
      return
    end

    amount = environment.highlighted_news_amount + environment.portal_news_amount
    news = environment.portal_community.news(amount, true)

    case params[:direction]
    when 'up'
      move_article_up(news, params[:index].to_i)
    when 'down'
      move_article_down(news, params[:index].to_i)
    end

    redirect_to action: :index
  end

  private

  def move_article_up(news, index)
    return unless index > 0 && index < news.size
    article = news[index]
    next_article = news[index - 1]
    Article.switch_orders(next_article, article)
  end

  def move_article_down(news, index)
    return unless index >= 0 && index < (news.size - 1)
    article = news[index]
    previous_article = news[index + 1]
    Article.switch_orders(article, previous_article)
  end

  def require_admin
    head :forbidden unless environment.admins.include? current_person
  end
end
