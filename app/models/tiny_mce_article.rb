class TinyMceArticle < TextArticle

  def self.short_description
    _('Text article with visual editor.')
  end

  def self.description
    _('Not accessible for visually impaired users.')
  end
  
  xss_terminate :only => [  ]

  xss_terminate :only => [ :name, :abstract, :body ], :with => 'white_list', :on => 'validation'

  include WhiteListFilter
  filter_iframes :abstract, :body, :whitelist => lambda { profile && profile.environment && profile.environment.trusted_sites_for_iframe }

end
