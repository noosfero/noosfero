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

  # FIXME we should not need all this just to write a link
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  def to_html
    content_tag('ul', children.map { |child| content_tag('li', link_to(child.name, child.url)) }, :class => 'folder-listing')
  end

end
