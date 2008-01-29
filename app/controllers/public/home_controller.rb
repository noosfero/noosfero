class HomeController < PublicController

  def index
    @articles = environment.recent_documents(10)
  end

end
