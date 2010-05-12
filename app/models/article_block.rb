class ArticleBlock < Block

  def self.description
    _('Display one of your contents')
  end

  def help
    _('This block displays one of your articles. You can edit the block to select which one of your articles is going to be displayed in the block.')
  end

  def content
    block = self
    lambda do
      block_title(block.title) +
      (block.article ? article_to_html(block.article) : _('Article not selected yet.'))
    end
  end

  def article_id
    self.settings[:article_id]
  end
  
  def article_id= value
    self.settings[:article_id] = value.blank? ? nil : value.to_i
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

end
