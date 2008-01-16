class HomeController < PublicController

  def index
    @articles = TextArticle.recent(nil, 10)
  end

end
