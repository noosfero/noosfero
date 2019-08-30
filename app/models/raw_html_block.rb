class RawHTMLBlock < Block
  def self.description
    _("Raw HTML")
  end

  def self.pretty_name
    _("Raw HTML")
  end

  settings_items :html, type: :text

  attr_accessible :html

  def has_macro?
    true
  end

  def editable?(user)
    user.has_permission?("edit_raw_html_block", environment)
  end

  def api_content(params = {})
    { html: html }
  end

  def display_api_content_by_default?
    true
  end
end
