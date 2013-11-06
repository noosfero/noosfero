class ContextContentBlock < Block
    
  settings_items :show_name, :type => :boolean, :default => true
  settings_items :show_image, :type => :boolean, :default => true
  settings_items :show_parent_content, :type => :boolean, :default => true
  settings_items :types, :type => Array, :default => ['UploadedFile']

  settings_items :limit, :type => :integer, :default => 6

  include Noosfero::Plugin::HotSpot
    
  def self.description
    _('Display context content')
  end

  def help
    _('This block displays content based on context.')
  end

  def available_content_types
    @available_content_types ||= [TinyMceArticle, TextileArticle, RawHTMLArticle, Event, Folder, Blog, UploadedFile, Forum, Gallery, RssFeed] + plugins.dispatch(:content_types)
  end

  def types=(new_types)
    settings[:types] = new_types.reject(&:blank?)
  end

  def content_image(content)
    block = self
    lambda do
      if content.image?
        image_tag(content.public_filename(:thumb))
      else
        extra_class = content.kind_of?(UploadedFile) ? "extension-#{content.extension}" : ''
        content_tag 'div', '', :class => "context-icon icon-#{content.class.icon_name(content)} #{extra_class}"
      end
    end
  end

  def contents(page)
    if page
      children = page.children.with_types(types).limit(limit)
      (children.blank? && show_parent_content) ? contents(page.parent) : children
    else
      nil
    end
  end

# FIXME
#  def footer
#    lambda do
#      link_to(_('View all'), '')
#    end
#  end

  def content(args={})
    block = self
    lambda do
      contents = block.contents(@page)
      if !contents.blank?
        render :file => 'blocks/context_content', :locals => {:block => block, :contents => contents}
      else
        ''
      end
    end
  end

end
