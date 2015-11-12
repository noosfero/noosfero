class RawHTMLBlock < Block

  def self.description
    _('Raw HTML')
  end

  def self.pretty_name
    _('Raw HTML')
  end

  settings_items :html, :type => :text

  attr_accessible :html

  def content(args={})
    (title.blank? ? '' : block_title(title)).html_safe + html.to_s.html_safe
  end

  def has_macro?
    true
  end
end
