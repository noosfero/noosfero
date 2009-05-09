# a base class for all text article types.  
class TextArticle < Article

  xss_terminate :only => [ :name, :abstract, :body ]
end
