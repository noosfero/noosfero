class Folder < Article

  acts_as_having_settings :field => :setting

  def self.short_description
    _('Folder')
  end

  def self.description
    _('A folder, inside which you can put other articles.')
  end

  def icon_name
    'folder'
  end

  # FIXME isn't this too much including just to be able to generate some HTML?
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  include ActionView::Helpers::AssetTagHelper
  include FolderHelper
  include DatesHelper
  def to_html
    content_tag('div', body) + tag('hr') + (children.empty? ? content_tag('em', _('(empty folder)')) : list_articles(children))
  end

  def folder?
    true
  end

  def can_display_hits?
    false
  end

end
