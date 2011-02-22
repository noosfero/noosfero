class RawHTMLBlock < Block

  def self.description
    _('Raw HTML')
  end

  settings_items :html, :type => :text

  def content
    (title.blank? ? '' : block_title(title)) + html.to_s
  end

end
