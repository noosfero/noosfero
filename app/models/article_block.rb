class ArticleBlock < Block

  def self.description
    _('Display one of your contents.')
  end

  def content
    article ? article.to_html : _('Article not selected yet.')
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
      begin
        @article = Article.find(article_id)
      rescue ActiveRecord::RecordNotFound
        # dangling reference, clear it
        @article = nil
        self.article_id = nil
        self.save!
      end
    end
    @article
  end

  def article=(obj)
    self.article_id = obj.id
    @article = obj
  end

  def editable?
    true
  end

end
