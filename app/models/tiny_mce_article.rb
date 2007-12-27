class TinyMceArticle < Article

  def self.short_description
    _('Text article with visual editor.')
  end

  def self.description
    _('Not accessible for visually impaired users.')
  end
end
