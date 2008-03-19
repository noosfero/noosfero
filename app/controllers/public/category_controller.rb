class CategoryController < PublicController

  # view the summary of one category
  def view
    # TODO: load articles, documents, etc so the view can list them.
    @recent_articles = category.recent_articles
    @recent_comments = category.recent_comments
    @most_commented_articles = category.most_commented_articles
  end

  attr_reader :category

  before_filter :load_category, :only => [ :view ]

end
