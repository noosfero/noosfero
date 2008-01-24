class TagsBlock < Block

  include TagsHelper
  include ActionView::Helpers::UrlHelper

  def self.description
    _('List count of contents by tag')
  end

  def content
    content_tag('h3', _('Tags'), :class => 'block-title') +
    tag_cloud(owner.tags, :id, owner.generate_url(:controller => 'profile', :action => 'tag') + '/', :max_size => 20, :min_size => 10)
  end

end
