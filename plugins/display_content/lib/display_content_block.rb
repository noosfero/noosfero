class DisplayContentBlock < Block

  MONTHS = [
    cN_('January'),
    cN_('February'),
    cN_('March'),
    cN_('April'),
    cN_('May'),
    cN_('June'),
    cN_('July'),
    cN_('August'),
    cN_('September'),
    cN_('October'),
    cN_('November'),
    cN_('December')
  ]

  AVAILABLE_SECTIONS = ['publish_date', 'title', 'abstract', 'body', 'image' ,'tags']

  settings_items :nodes, :type => Array, :default => []
  settings_items :sections,
                 :type => Array,
                 :default => [{:value => 'publish_date', :checked => true},
                              {:value => 'title', :checked => true},
                              {:value => 'abstract', :checked => true}]
  settings_items :display_folder_children, :type => :boolean, :default => true
	  settings_items :types, :type => Array, :default => ['TextArticle']
  settings_items :order_by_recent, :type => :boolean, :default => :true
  settings_items :content_with_translations, :type => :boolean, :default => :true
  settings_items :limit_to_show, :type => :integer, :default => 6

  attr_accessible :sections, :checked_nodes, :display_folder_children, :types, :order_by_recent, :limit_to_show, :content_with_translations

  def self.description
    _('Display your contents')
  end

  def help
    _('This block displays articles chosen by you. You can edit the block to select which of your articles is going to be displayed in the block.')
  end

  def section_name(section)
    {
      'publish_date' => _('Publish date'),
      'title' => c_('Title'),
      'abstract' => _('Abstract'),
      'body' => c_('Body'),
      'image' => c_('Image'),
      'tags' => c_('Tags')
    }[section] || section
  end

  alias :orig_sections :sections
  def sections
    available_sections = AVAILABLE_SECTIONS
    available_sections = available_sections - orig_sections.map{|e|e[:value]}
    sections = available_sections.map do |section|
      {:value => section, :checked => false}
    end
    sections + orig_sections
  end

  def available_content_types
    @available_content_types ||= [TextArticle, UploadedFile, Event, Folder, Blog, Forum, Gallery, RssFeed] + plugins.dispatch(:content_types)
    checked_types = types.map {|t| t.constantize}
    checked_types + (@available_content_types - checked_types)
  end

  #FIXME make this test copy of Context Content
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

  def checked_nodes= params
    self.nodes = params.keys
  end

  before_save :expand_nodes

  def expand_nodes
    return self.nodes if self.holder.nil?

    articles = self.holder.articles.where(:id => nodes)
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

  VALID_CONTENT = ['TextArticle', 'Folder', 'Blog', 'Forum']

  include Noosfero::Plugin::HotSpot

  def articles_of_parent(parent = nil)
    return [] if self.holder.nil?
    types = VALID_CONTENT + plugins.dispatch(:content_types).map(&:name)
    holder.articles.where(type: types, parent_id: if parent.nil? then nil else parent end)
  end

  def docs
    order_string = "published_at"
    order_string += " DESC" if order_by_recent

    limit_final = [limit_to_show, 0].max

    documents = owner.articles.order(order_string)
      .where(articles: {type: self.types})
      .includes(:profile, :image, :tags)
    if nodes.present?
      nodes_conditions  = 'articles.id IN(:nodes)'
      nodes_conditions << ' OR articles.parent_id IN(:nodes) ' if display_folder_children
      documents = documents.where nodes_conditions, nodes: nodes
    end
    documents = documents.limit limit_final if display_folder_children

    if content_with_translations
      documents = documents.native_translations
      documents.replace documents.map{ |p| p.get_translation_to(FastGettext.locale) }.compact
    end

    documents
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
