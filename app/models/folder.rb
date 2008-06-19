class Folder < Article

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
  def to_html
    content_tag('div', body) + tag('hr') + list_articles(children)
  end

  def folder?
    true
  end

end
