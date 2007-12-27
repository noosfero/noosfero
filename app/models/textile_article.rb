class TextileArticle < Article

  def self.short_description
    _('Text article with Textile markup language')
  end

  def self.description
    _('Accessible alternative for visually impaired users.')
  end

  def to_html
    RedCloth.new(self.body).to_html
  end

end
