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
    if params[:index].nil? || !params[:direction].in?(['up', 'down'])
      head :bad_request
      return
    end

    amount = environment.highlighted_news_amount + environment.portal_news_amount
    news = environment.portal_community.news(amount, true)
    normalize_orders!(news)

    case params[:direction]
    when 'up'
      move_article_up(news, params[:index].to_i)
    when 'down'
      move_article_down(news, params[:index].to_i)
    end

    redirect_to action: :index
  end

  private

  def normalize_orders!(news)
    return unless news.any? { |n| n.metadata['order'].nil? }
    news.each_with_index do |article, index|
      article.metadata['order'] = index
      article.save
    end
  end

  def move_article_up(news, index)
    if index > 0 && index < news.size
      article = news[index]
      previous_article = news[index - 1]
      switch_orders(article, previous_article)
    end
  end

  def move_article_down(news, index)
    if index >= 0 && index < (news.size - 1)
      article = news[index]
      next_article = news[index + 1]
      switch_orders(article, next_article)
    end
  end

  def switch_orders(first_article, second_article)
    first_order = first_article.metadata['order']
    second_order = second_article.metadata['order']

    first_article.metadata['order'] = second_order
    second_article.metadata['order'] = first_order

    first_article.save
    second_article.save
  end

  def require_admin
    head :forbidden unless environment.admins.include? current_person
  end
end
