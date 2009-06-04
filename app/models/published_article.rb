class PublishedArticle < Article
  before_create do |article|
    parent = article.reference_article.parent
    if parent && parent.blog? && article.profile.has_blog?
      article.parent = article.profile.blog
    end
  end

  def self.short_description
    _('Reference to other article')
  end

  def self.description
    _('A reference to another article published in another profile')    
  end

  def body
    reference_article.body
  end

  before_validation_on_create :update_name
  def update_name
    self.name ||= self.reference_article.name
  end

  def author
    if reference_article
      reference_article.author
    else
      profile
    end
  end

end
