class TextileArticle < TextArticle
  include SanitizeHelper

  def self.short_description
    _('Text article with Textile markup language')
  end

  def self.description
    _('Accessible alternative for visually impaired users.')
  end

  def to_html(options ={})
    convert_to_html(body)
  end

  def lead(length = nil)
    if abstract.blank?
      super
    else
      convert_to_html(abstract)
    end
  end

  def notifiable?
    true
  end

  def can_display_media_panel?
    true
  end

  protected

  def convert_to_html(textile)
    converter = RedCloth.new(textile|| '')
    converter.hard_breaks = false
    sanitize_html(converter.to_html, :white_list)
  end

end
