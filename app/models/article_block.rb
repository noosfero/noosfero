class ArticleBlock < Block

  def self.description
    _('Display one of your contents.')
  end

  def content
    article.to_html
  end

  def article_id
    self.settings[:article_id]
  end
  
  def article_id= value
    self.settings[:article_id] = value
  end

  def article(reload = false)
    @article = nil if reload
    if @article || article_id
      @article = Article.find(article_id)
    end
    @article
  end

  def article=(obj)
    self.article_id = obj.id
    @article = obj
  end

end
