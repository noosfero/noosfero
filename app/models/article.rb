class Article < ActiveRecord::Base

  # xss_terminate plugin can't sanitize array fields
  before_save :sanitize_tag_list

  belongs_to :profile
  validates_presence_of :profile_id, :name
  validates_presence_of :slug, :path, :if => lambda { |article| !article.name.blank? }

  validates_uniqueness_of :slug, :scope => ['profile_id', 'parent_id'], :message => N_('%{fn} (the code generated from the article name) is already being used by another article.'), :if => lambda { |article| !article.slug.blank? }

  belongs_to :last_changed_by, :class_name => 'Person', :foreign_key => 'last_changed_by_id'

  has_many :comments, :dependent => :destroy, :order => 'created_at asc'

  has_many :article_categorizations, :conditions => [ 'articles_categories.virtual = ?', false ]
  has_many :categories, :through => :article_categorizations

  acts_as_having_settings :field => :setting

  settings_items :display_hits, :type => :boolean, :default => true

  belongs_to :reference_article, :class_name => "Article", :foreign_key => 'reference_article_id'

  before_create do |article|
    article.published_at = article.created_at if article.published_at.nil?
  end

  xss_terminate :only => [ :name ]

  def self.human_attribute_name(attrib)
    case attrib.to_sym
    when :name
      _('Title')
    else
      _(self.superclass.human_attribute_name(attrib))
    end
  end

  def css_class_name
    self.class.name.underscore.dasherize
  end

  def pending_categorizations
    @pending_categorizations ||= []
  end

  def add_category(c)
    if self.id
      ArticleCategorization.add_category_to_article(c, self)
    else
      pending_categorizations << c
    end
  end

  def category_ids=(ids)
    ArticleCategorization.remove_all_for(self)
    ids.uniq.each do |item|
      add_category(Category.find(item)) unless item.to_i.zero?
    end
  end

  after_create :create_pending_categorizations
  def create_pending_categorizations
    pending_categorizations.each do |item|
      ArticleCategorization.add_category_to_article(item, self)
    end
    pending_categorizations.clear
  end

  before_save do |article|
    if article.parent
      article.public_article = article.parent.public_article
    end
    true
  end

  acts_as_taggable  
  N_('Tag list')

  acts_as_filesystem

  acts_as_versioned

  acts_as_searchable :additional_fields => [ :comment_data ]

  def comment_data
    comments.map {|item| [item.title, item.body].join(' ') }.join(' ')
  end

  before_update do |article|
    article.advertise = true
  end
  
  # retrieves all articles belonging to the given +profile+ that are not
  # sub-articles of any other article.
  def self.top_level_for(profile)
    self.find(:all, :conditions => [ 'parent_id is null and profile_id = ?', profile.id ])
  end

  # retrieves the latest +limit+ articles, sorted from the most recent to the
  # oldest.
  #
  # Only includes articles where advertise == true
  def self.recent(limit, extra_conditions = {})
    # FIXME this method is a horrible hack
    options = { :limit => limit,
                :conditions => [
                  "advertise = ? AND
                  public_article = ? AND
                  published = ? AND
                  profiles.public_profile = ? AND
                  ((articles.type != ? and articles.type != ? and articles.type != ?) OR articles.type is NULL)", true, true, true, true, 'UploadedFile', 'RssFeed', 'Blog'
                ],
                :include => 'profile',
                :order => 'articles.published_at desc, articles.id desc'
              }
    if ( scoped_methods && scoped_methods.last &&
         scoped_methods.last[:find] &&
         scoped_methods.last[:find][:joins] &&
         scoped_methods.last[:find][:joins].index('profiles') )
      options.delete(:include)
    end
    if extra_conditions == {}
      self.find(:all, options)
    else
      with_scope :find => {:conditions => extra_conditions} do
        self.find(:all, options)
      end
    end
  end

  # retrives the most commented articles, sorted by the comment count (largest
  # first)
  def self.most_commented(limit)
    find(:all, :order => 'comments_count DESC', :limit => limit)
  end

  # produces the HTML code that is to be displayed as this article's contents.
  #
  # The implementation in this class just provides the +body+ attribute as the
  # HTML.  Other article types can override this method to provide customized
  # views of themselves.
  def to_html(options = {})
    body
  end

  # returns the data of the article. Must be overriden in each subclass to
  # provide the correct content for the article. 
  def data
    body
  end

  # provides the icon name to be used for this article. In this class this
  # method just returns 'text-html', but subclasses may (and should) override
  # to return their specific icons.
  #
  # FIXME use mime_type and generate this name dinamically
  def icon_name
    'text-html'
  end

  def mime_type
    'text/html'
  end

  def mime_type_description
    _('HTML Text document')
  end

  def self.description
    raise NotImplementedError, "#{self} does not implement #description"
  end

  def self.short_description
    raise NotImplementedError, "#{self} does not implement #short_description"
  end

  def title
    name
  end

  def belongs_to_blog?
    self.parent and self.parent.blog?
  end

  def url
    @url ||= self.profile.url.merge(:page => path.split('/'))
  end

  def view_url
    @view_url ||= image? ? url.merge(:view => true) : url
  end

  def allow_children?
    true
  end

  def folder?
    false
  end

  def blog?
    false
  end

  def display_to?(user)
    if self.public_article
      self.profile.display_info_to?(user)
    else
      if user.nil?
        false
      else
        (user == self.profile) || user.has_permission?('view_private_content', self.profile)
      end
    end
  end

  def allow_post_content?(user = nil)
    user && (user.has_permission?('post_content', profile) || allow_publish_content?(user) && (user == self.creator))
  end

  def allow_publish_content?(user = nil)
    user && user.has_permission?('publish_content', profile)
  end

  def comments_updated
    ferret_update
  end

  def accept_category?(cat)
    !cat.is_a?(ProductCategory)
  end

  def public?
    profile.public? && public_article
  end

  def copy(options)
    attrs = attributes.reject! { |key, value| article_attr_blacklist.include?(key) }
    attrs.merge!(options)
    self.class.create(attrs)
  end

  def article_attr_blacklist
    ['id', 'profile_id', 'parent_id', 'slug', 'path', 'updated_at', 'created_at', 'last_changed_by_id', 'version', 'lock_version', 'type', 'children_count', 'comments_count', 'hits']
  end

  def self.find_by_old_path(old_path)
    find(:first, :include => :versions, :conditions => ['article_versions.path = ?', old_path], :order => 'article_versions.id desc')
  end

  def hit
    self.class.connection.execute('update articles set hits = hits + 1 where id = %d' % self.id.to_i)
    self.hits += 1
  end

  def can_display_hits?
    true
  end

  def display_hits?
    can_display_hits? && display_hits
  end

  def image?
    false
  end

  def display_as_gallery?
    false
  end

  def author
    last_changed_by ||
      profile
  end

  alias :active_record_cache_key :cache_key
  def cache_key(params = {}, the_profile = nil)
    active_record_cache_key +
      (allow_post_content?(the_profile) ? "-owner" : '') +
      (params[:npage] ? "-npage-#{params[:npage]}" : '') +
      (params[:year] ? "-year-#{params[:year]}" : '') +
      (params[:month] ? "-month-#{params[:month]}" : '')
  end

  def first_paragraph
    to_html =~ /(.*<\/p>)/
    $1
  end

  def self.find_tagged_with(tag)
    self.find(:all, :include => :taggings, :conditions => ['taggings.tag_id = ?', tag.id])
  end

  def creator
    creator_id = versions[0][:last_changed_by_id]
    creator_id && Profile.find(creator_id)
  end

  private

  def sanitize_tag_list
    sanitizer = HTML::FullSanitizer.new
    self.tag_list.names.map!{|i| sanitizer.sanitize(i) }
  end

end
