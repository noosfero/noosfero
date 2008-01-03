class HomeController < PublicController

  design :holder => 'environment'

  def index
    @articles = TextArticle.recent(nil, 10)
  end

end
