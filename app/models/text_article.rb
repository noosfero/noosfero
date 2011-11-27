# a base class for all text article types.  
class TextArticle < Article

  xss_terminate :only => [ :name ], :on => 'validation'

  include Noosfero::TranslatableContent

  def self.icon_name(article = nil)
    if article && !article.parent.nil? && article.parent.kind_of?(Blog)
      Blog.icon_name
    else
      Article.icon_name
    end
  end

end
