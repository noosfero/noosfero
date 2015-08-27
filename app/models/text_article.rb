require 'noosfero/translatable_content'

# a base class for all text article types.
class TextArticle < Article

  xss_terminate :only => [ :name ], :on => 'validation'

  def self.type_name
    _('Article')
  end

  include Noosfero::TranslatableContent

  def self.icon_name(article = nil)
    if article && !article.parent.nil? && article.parent.kind_of?(Blog)
      Blog.icon_name
    else
      Article.icon_name
    end
  end

  def can_display_versions?
    true
  end

  before_save :set_relative_path

  def set_relative_path
    parsed = Nokogiri::HTML.fragment(self.body.to_s)
    parsed.css('img[src]').each { |i| change_element_path(i, 'src') }
    parsed.css('a[href]').each { |i| change_element_path(i, 'href') }
    self.body = parsed.to_html
  end

  def change_element_path(el, attribute)
    fullpath = /(https?):\/\/(#{profile.default_hostname})(:\d+)?(\/.*)/.match(el[attribute])
    if fullpath
      domain = fullpath[2]
      path = fullpath[4]
      el[attribute] = path if domain == profile.default_hostname
    end
  end

  def display_preview?
    parent && parent.kind_of?(Blog) && parent.display_preview
  end

end
