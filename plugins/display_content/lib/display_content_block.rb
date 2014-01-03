class DisplayContentBlock < Block

  settings_items :nodes, :type => Array, :default => []
  settings_items :chosen_attributes, :type => Array, :default => ['title']
  settings_items :display_folder_children, :type => :boolean, :default => true

  def self.description
    _('Display your contents')
  end

  def help
    _('This block displays articles chosen by you. You can edit the block to select which of your articles is going to be displayed in the block.')
  end

  def checked_nodes= params
    self.nodes = params.keys
  end

  before_save :expand_nodes

  def expand_nodes
    return self.nodes if self.holder.nil?

    articles = self.holder.articles.find(nodes)
    children = articles.map { |article| article.children }.compact.flatten

    if display_folder_children
      articles = articles - children
    else
      articles = (articles + children).uniq
    end

    self.nodes = articles.map(&:id)
  end

  def parent_nodes
    @parent_nodes ||= self.holder.articles.find(nodes).map { |article| get_parent(article) }.compact.flatten
  end

  VALID_CONTENT = ['RawHTMLArticle', 'TextArticle', 'TextileArticle', 'TinyMceArticle', 'Folder', 'Blog', 'Forum']

  def articles_of_parent(parent = nil)
    return [] if self.holder.nil?
    holder.articles.find(:all, :conditions => {:type => VALID_CONTENT, :parent_id => (parent.nil? ? nil : parent)})
  end

  include ActionController::UrlWriter
  def content(args={})
    extra_condition = display_folder_children ? 'OR articles.parent_id IN(:nodes)':''
    docs = nodes.blank? ? [] : owner.articles.find(:all, :conditions => ["(articles.id IN(:nodes) #{extra_condition}) AND articles.type IN(:types)", {:nodes => self.nodes, :types => VALID_CONTENT}])

    block_title(title) +
    content_tag('ul', docs.map {|item|
      if !item.folder?
        content_tag('li',
          (display_attribute?('title') ? content_tag('div', link_to(h(item.title), item.url), :class => 'title') : '') +
          (display_attribute?('abstract') ? content_tag('div', item.abstract ,:class => 'lead') : '') +
          (display_attribute?('body') ? content_tag('div', item.body ,:class => 'body') : '')
        )
      end
    }.join("\n"))

  end

  def url_params
    params = {:block_id => self.id}
    if self.owner.is_a?(Profile)
      params.merge!(:controller => "display_content_plugin_myprofile")
      params.merge!(:profile => self.holder.identifier)
    else
      params.merge!( :controller => "display_content_plugin_admin")
    end
    params
  end

  def display_attribute?(attr)
    chosen_attributes.include?(attr)
  end

  protected

  def holder
    return nil if self.box.nil? || self.box.owner.nil?
    if self.box.owner.kind_of?(Environment)
      return nil if self.box.owner.portal_community.nil?
      self.box.owner.portal_community
    else
      self.box.owner
    end
  end

  def get_parent(article)
    return [] if article.parent_id.nil?
    parents = [article.parent.id] + get_parent(article.parent)
    return parents
  end

  def self.expire_on
      { :profile => [:article], :environment => [:article] }
  end

end
