# a base class for all text article types.
class TextArticle < Article

  def self.short_description
    _('Text article')
  end

  def self.description
    _('Text article to create user content.')
  end

  xss_terminate :only => [ :name, :body, :abstract ], :with => 'white_list', :on => 'validation', :if => lambda { |a| !a.editor?(Article::Editor::TEXTILE) && !a.editor?(Article::Editor::RAW_HTML) }

  include WhiteListFilter
  filter_iframes :abstract, :body
  def iframe_whitelist
    profile && profile.environment && profile.environment.trusted_sites_for_iframe
  end

  def self.type_name
    _('Article')
  end

  include TranslatableContent

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

  def can_display_media_panel?
    true
  end

  def self.can_display_blocks?
    false
  end

  def notifiable?
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

  def to_html(options ={})
    content = super(options)
    content = convert_textile_to_html(content) if self.editor?(Article::Editor::TEXTILE)
    content
  end

  def lead(length = nil)
    content = super(length)
    content = convert_textile_to_html(content) if self.editor?(Article::Editor::TEXTILE)
    content
  end

  protected

  def convert_textile_to_html(textile)
    converter = RedCloth.new(textile|| '')
    converter.hard_breaks = false
    sanitize_html(converter.to_html, :white_list)
  end

end
