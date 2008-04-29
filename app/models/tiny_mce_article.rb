class TinyMceArticle < TextArticle

  def self.short_description
    _('Text article with visual editor.')
  end

  def self.description
    _('Not accessible for visually impaired users.')
  end
  
  xss_terminate :except => [ :abstract, :body ]
  xss_terminate :only => [ :abstract, :body ], :with => 'white_list'

end
