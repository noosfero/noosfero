class DisplayContentBlock < Block

  MONTHS = [
    N_('January'),
    N_('February'),
    N_('March'),
    N_('April'),
    N_('May'),
    N_('June'),
    N_('July'),
    N_('August'),
    N_('September'),
    N_('October'),
    N_('November'),
    N_('December')
  ]

  settings_items :nodes, :type => Array, :default => []
  settings_items :sections,
                 :type => Array,
                 :default => [{:name => _('Publish date'), :checked => true},
                              {:name => _('Title'), :checked => true},
                              {:name => _('Abstract'), :checked => true},
                              {:name => _('Body'), :checked => false},
                              {:name => _('Image'), :checked => false},
                              {:name => _('Tags'), :checked => false}]
  settings_items :display_folder_children, :type => :boolean, :default => true

  attr_accessible :sections, :checked_nodes, :display_folder_children

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
    @parent_nodes ||= self.holder.articles.where(:id => nodes).map { |article| get_parent(article) }.compact.flatten
  end

  VALID_CONTENT = ['RawHTMLArticle', 'TextArticle', 'TextileArticle', 'TinyMceArticle', 'Folder', 'Blog', 'Forum']

  include Noosfero::Plugin::HotSpot

  def articles_of_parent(parent = nil)
    return [] if self.holder.nil?
    types = VALID_CONTENT + plugins.dispatch(:content_types).map(&:name)
    holder.articles.find(:all, :conditions => {:type => types, :parent_id => (parent.nil? ? nil : parent)})
  end

  def content(args={})
    block = self
    extra_condition = display_folder_children ? 'OR articles.parent_id IN(:nodes)':''
    docs = nodes.blank? ? [] : owner.articles.find(:all, :conditions => ["(articles.id IN(:nodes) #{extra_condition}) AND articles.type IN(:types)", {:nodes => self.nodes, :types => VALID_CONTENT}])

    proc do
      block.block_title(block.title) +
        content_tag('ul', docs.map {|item|
        if !item.folder?
          content_sections = ''
          read_more_section = ''
          tags_section = ''

          block.sections.select { |section|
            case section[:name]
            when 'Publish date'
              content_sections += (block.display_section?(section) ? (content_tag('div', block.show_date(item.published_at, false), :class => 'published-at') ) : '')
            when 'Title'
              content_sections += (block.display_section?(section) ? (content_tag('div', link_to(h(item.title), item.url), :class => 'title') ) : '')
            when 'Abstract'
              content_sections += (block.display_section?(section) ? (content_tag('div', item.abstract , :class => 'lead')) : '' )
              if block.display_section?(section)
                read_more_section = content_tag('div', link_to(_('Read more'), item.url), :class => 'read_more')
              end
            when 'Body'
              content_sections += (block.display_section?(section) ? (content_tag('div', item.body ,:class => 'body')) : '' )
            when 'Image'
              image_section = image_tag item.image.public_filename if item.image
              if !image_section.blank?
                content_sections += (block.display_section?(section) ? (content_tag('div', link_to( image_section, item.url ) ,:class => 'image')) : '' )
              end
            when 'Tags'
              if !item.tags.empty?
                tags_section = item.tags.map { |t| content_tag('span', t.name) }.join("")
                content_sections += (block.display_section?(section) ? (content_tag('div', tags_section, :class => 'tags')) : '')
              end
            end
          }

          content_sections += read_more_section if !read_more_section.blank?

          content_tag('li', content_sections)
        end
      }.join(" "))
    end
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

  def display_section?(section)
    section[:checked]
  end

  #FIXME: this should be in a helper
  def show_date(date, use_numbers = false, year=true)
    if date && use_numbers
      date_format = year ? _('%{month}/%{day}/%{year}') : _('%{month}/%{day}')
      date_format % { :day => date.day, :month => date.month, :year => date.year }
    elsif date
      date_format = year ? _('%{month_name} %{day}, %{year}') : _('%{month_name} %{day}')
      date_format % { :day => date.day, :month_name => month_name(date.month), :year => date.year }
    else
      ''
    end
  end

  def month_name(n)
    _(MONTHS[n-1])
  end

  protected

  def holder
    return nil if self.box.nil? || self.owner.nil?
    if self.owner.kind_of?(Environment)
      return nil if self.owner.portal_community.nil?
      self.owner.portal_community
    else
      self.owner
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
