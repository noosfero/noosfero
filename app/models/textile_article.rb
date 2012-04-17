class TextileArticle < TextArticle

  def self.short_description
    _('Text article with Textile markup language')
  end

  def self.description
    _('Accessible alternative for visually impaired users.')
  end

  def to_html(options ={})
    convert_to_html(body)
  end

  def lead
    if abstract.blank?
      super
    else
      convert_to_html(abstract)
    end
  end

  def notifiable?
    true
  end

  protected

  def convert_to_html(textile)
    @@sanitizer ||= HTML::WhiteListSanitizer.new
    converter = RedCloth.new(textile|| '')
    converter.hard_breaks = false
    @@sanitizer.sanitize(converter.to_html)
  end

end
