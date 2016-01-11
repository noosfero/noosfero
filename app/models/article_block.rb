class ArticleBlock < Block

  attr_accessible :article_id

  def self.description
    _('Display one of your contents.')
  end

  def self.short_description
    _('Show one article')
  end

  def self.pretty_name
    _('Article')
  end

  def help
    _('This block displays one of your articles. You can edit the block to select which one of your articles is going to be displayed in the block.')
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

  def available_articles
    return [] if self.owner.nil?
    self.owner.kind_of?(Environment) ? self.owner.portal_community.articles : self.owner.articles
  end

  def posts_per_page
    self.settings[:posts_per_page] or 1
  end

  def posts_per_page= value
    value = value.to_i
    self.settings[:posts_per_page] = value if value > 0
  end

  settings_items :visualization_format, :type => :string, :default => 'short'

  def self.expire_on
      { :profile => [:article], :environment => [:article] }
  end

end
