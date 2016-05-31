class ContextContentPlugin::ContextContentBlock < Block

  settings_items :show_name, :type => :boolean, :default => true
  settings_items :show_image, :type => :boolean, :default => true
  settings_items :use_parent_title, :type => :boolean, :default => false
  settings_items :show_parent_content, :type => :boolean, :default => true
  settings_items :types, :type => Array, :default => ['UploadedFile']
  settings_items :limit, :type => :integer, :default => 6

  attr_accessible :show_image, :show_name, :use_parent_title, :show_parent_content, :types

  alias :profile :owner

  include Noosfero::Plugin::HotSpot

  def self.description
    _('Display context content')
  end

  def help
    _('This block displays content based on context.')
  end

  def available_content_types
    @available_content_types ||= [UploadedFile, Event, TinyMceArticle, TextileArticle, RawHTMLArticle, Folder, Blog, Forum, Gallery, RssFeed] + plugins.dispatch(:content_types)
    checked_types = types.map {|t| t.constantize}
    checked_types + (@available_content_types - checked_types)
  end

  def first_content_types
    available_content_types.first(first_types_count)
  end

  def more_content_types
    available_content_types.drop(first_types_count)
  end

  def first_types_count
    [2, types.length].max
  end

  def types=(new_types)
    settings[:types] = new_types.reject(&:blank?)
  end

  def contents(page, p=1)
    return @children unless @children.blank?
    if page
      @children = page.children.with_types(types).order(:name).paginate(:per_page => limit, :page => p)
      (@children.blank? && show_parent_content) ? contents(page.parent, p) : @children
    else
      nil
    end
  end

  def parent_title(contents)
    return nil if contents.blank?
    contents.first.parent.name
  end

  def cacheable?
    false
  end

end
