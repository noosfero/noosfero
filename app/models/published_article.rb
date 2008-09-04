class PublishedArticle < Article
  belongs_to :reference_article, :class_name => "Article"

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
end
