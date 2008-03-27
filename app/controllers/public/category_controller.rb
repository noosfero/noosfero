class CategoryController < PublicController

  # view the summary of one category
  def view
    send('action_' + @category.class.name.underscore) 
  end

  attr_reader :category

  before_filter :load_category, :only => [ :view ]
  private

  def action_product_category
    @products = category.products
    @enterprises = category.products.map{|p| p.enterprise}.flatten.uniq
    @users = category.consumers
  end

  def action_category
    # TODO: load articles, documents, etc so the view can list them.
    @recent_articles = category.recent_articles
    @recent_comments = category.recent_comments
    @most_commented_articles = category.most_commented_articles
  end
  alias :action_region :action_category

end
