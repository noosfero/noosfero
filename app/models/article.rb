require 'hpricot'

class Article < ActiveRecord::Base

  SEARCHABLE_FIELDS = {
    :name => 10,
    :abstract => 3,
    :body => 2,
    :slug => 1,
    :filename => 1,
  }

  SEARCH_FILTERS = %w[
    more_recent
    more_popular
    more_comments
  ]

  SEARCH_DISPLAYS = %w[full]

  def self.default_search_display
    'full'
  end

  #FIXME This is necessary because html is being generated on the model...
  include ActionView::Helpers::TagHelper

  # use for internationalizable human type names in search facets
  # reimplement on subclasses
  def self.type_name
    _('Content')
  end

  track_actions :create_article, :after_create, :keep_params => [:name, :url, :lead, :first_image], :if => Proc.new { |a| a.is_trackable? && !a.image? }

  # xss_terminate plugin can't sanitize array fields
  before_save :sanitize_tag_list

  before_create do |article|
    if article.last_changed_by_id
      article.author_name = Person.find(article.last_changed_by_id).name
    end
  end

  belongs_to :profile
  validates_presence_of :profile_id, :name
  validates_presence_of :slug, :path, :if => lambda { |article| !article.name.blank? }

  validates_length_of :name, :maximum => 150

  validates_uniqueness_of :slug, :scope => ['profile_id', 'parent_id'], :message => N_('The title (article name) is already being used by another article, please use another title.'), :if => lambda { |article| !article.slug.blank? }

  belongs_to :last_changed_by, :class_name => 'Person', :foreign_key => 'last_changed_by_id'

  has_many :comments, :class_name => 'Comment', :foreign_key => 'source_id', :dependent => :destroy, :order => 'created_at asc'

  has_many :article_categorizations, :conditions => [ 'articles_categories.virtual = ?', false ]
  has_many :categories, :through => :article_categorizations

  has_many :article_categorizations_including_virtual, :class_name => 'ArticleCategorization'
  has_many :categories_including_virtual, :through => :article_categorizations_including_virtual, :source => :category

  acts_as_having_settings :field => :setting

  settings_items :display_hits, :type => :boolean, :default => true
  settings_items :author_name, :type => :string, :default => ""
  settings_items :allow_members_to_edit, :type => :boolean, :default => false
  settings_items :moderate_comments, :type => :boolean, :default => false
  settings_items :followers, :type => Array, :default => []

  belongs_to :reference_article, :class_name => "Article", :foreign_key => 'reference_article_id'

  belongs_to :license

  has_many :translations, :class_name => 'Article', :foreign_key => :translation_of_id
  belongs_to :translation_of, :class_name => 'Article', :foreign_key => :translation_of_id
  before_destroy :rotate_translations

  before_create do |article|
    article.published_at ||= Time.now
    if article.reference_article && !article.parent
      parent = article.reference_article.parent
      if parent && parent.blog? && article.profile.has_blog?
        article.parent = article.profile.blog
      end
    end
  end

  after_destroy :destroy_activity
  def destroy_activity
    self.activity.destroy if self.activity
  end

  xss_terminate :only => [ :name ], :on => 'validation', :with => 'white_list'

  named_scope :in_category, lambda { |category|
    {:include => 'categories_including_virtual', :conditions => { 'categories.id' => category.id }}
  }

  named_scope :by_range, lambda { |range| {
    :conditions => [
      'published_at BETWEEN :start_date AND :end_date', { :start_date => range.first, :end_date => range.last }
    ]
  }}

  URL_FORMAT = /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?\Z/ix

  validates_format_of :external_link, :with => URL_FORMAT, :if => lambda { |article| !article.external_link.blank? }
  validate :known_language
  validate :used_translation
  validate :native_translation_must_have_language
  validate :translation_must_have_language

  validate :no_self_reference
  validate :no_cyclical_reference, :if => 'parent_id.present?'

  def no_self_reference
    errors.add(:parent_id, _('self-reference is not allowed.')) if id && parent_id == id
  end

  def no_cyclical_reference
    current_parent = Article.find(parent_id)
    while current_parent
      if current_parent == self
        errors.add(:parent_id, _('cyclical reference is not allowed.'))
        break
      end
      current_parent = current_parent.parent
    end
  end


  def is_trackable?
    self.published? && self.notifiable? && self.advertise? && self.profile.public_profile
  end

  def external_link=(link)
    if !link.blank? && link !~ /^[a-z]+:\/\//i
      link = 'http://' + link
    end
    self[:external_link] = link
  end

  def action_tracker_target
    self.profile
  end

  def self.human_attribute_name(attrib)
    case attrib.to_sym
    when :name
      _('Title')
    else
      _(self.superclass.human_attribute_name(attrib))
    end
  end

  def css_class_list
    [self.class.name.underscore.dasherize]
  end

  def css_class_name
    [css_class_list].flatten.compact.join(' ')
  end

  def pending_categorizations
    @pending_categorizations ||= []
  end

  def add_category(c, reload=false)
    if new_record?
      pending_categorizations << c
    else
      ArticleCategorization.add_category_to_article(c, self)
      self.categories(reload)
    end
  end

  def category_ids=(ids)
    ArticleCategorization.remove_all_for(self)
    ids.uniq.each do |item|
      add_category(Category.find(item)) unless item.to_i.zero?
    end
    self.categories(true)
  end

  after_create :create_pending_categorizations
  def create_pending_categorizations
    pending_categorizations.each do |item|
      ArticleCategorization.add_category_to_article(item, self)
    end
    self.categories(true)
    pending_categorizations.clear
  end

  acts_as_taggable  
  N_('Tag list')

  acts_as_filesystem

  acts_as_versioned

  def comment_data
    comments.map {|item| [item.title, item.body].join(' ') }.join(' ')
  end

  before_update do |article|
    article.advertise = true
  end

  before_save do |article|
    article.parent = article.parent_id ? Article.find(article.parent_id) : nil
    parent_path = article.parent ? article.parent.path : nil
    article.path = [parent_path, article.slug].compact.join('/')
  end

  # retrieves all articles belonging to the given +profile+ that are not
  # sub-articles of any other article.
  named_scope :top_level_for, lambda { |profile|
    {:conditions => [ 'parent_id is null and profile_id = ?', profile.id ]}
  }

  named_scope :join_profile, :joins => [:profile]

  named_scope :public,
    :conditions => [ "advertise = ? AND published = ? AND profiles.visible = ? AND profiles.public_profile = ?", true, true, true, true ]

  # retrives the most commented articles, sorted by the comment count (largest
  # first)
  def self.most_commented(limit)
    paginate(:order => 'comments_count DESC', :page => 1, :per_page => limit)
  end

  named_scope :relevant_as_recent, :conditions => ["(articles.type != 'UploadedFile' and articles.type != 'RssFeed' and articles.type != 'Blog') OR articles.type is NULL"]

  def self.recent(limit = nil, extra_conditions = {}, pagination = true)
    result = scoped({:conditions => extra_conditions}).
      public.
      relevant_as_recent.
      limit(limit).
      order(['articles.published_at desc', 'articles.id desc'])

    if !( scoped_methods && scoped_methods.last &&
        scoped_methods.last[:find] &&
        scoped_methods.last[:find][:joins] &&
        scoped_methods.last[:find][:joins].index('profiles') )
      result = result.includes(:profile)
    end

    pagination ? result.paginate({:page => 1, :per_page => limit}) : result
  end

  # produces the HTML code that is to be displayed as this article's contents.
  #
  # The implementation in this class just provides the +body+ attribute as the
  # HTML.  Other article types can override this method to provide customized
  # views of themselves.
  # (To override short format representation, override the lead method)
  def to_html(options = {})
    if options[:format] == 'short'
      display_short_format(self)
    else
      body || ''
    end
  end

  include ApplicationHelper
  def reported_version(options = {})
    article = self
    search_path = File.join(Rails.root, 'app', 'views', 'shared', 'reported_versions')
    partial_path = File.join('shared', 'reported_versions', partial_for_class_in_view_path(article.class, search_path))
    lambda { render_to_string(:partial => partial_path, :locals => {:article => article}) }
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
  def self.icon_name(article = nil)
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

  include ActionView::Helpers::TextHelper
  def short_title
    truncate self.title, :length => 15, :omission => '...'
  end

  def belongs_to_blog?
    self.parent and self.parent.blog?
  end
  
  def belongs_to_forum?
    self.parent and self.parent.forum?
  end

  def info_from_last_update
    last_comment = comments.last
    if last_comment
      {:date => last_comment.created_at, :author_name => last_comment.author_name, :author_url => last_comment.author_url}
    else
      {:date => updated_at, :author_name => author_name, :author_url => author_url}
    end
  end

  def url
    @url ||= self.profile.url.merge(:page => path.split('/'))
  end

  def view_url
    @view_url ||= is_a?(UploadedFile) ? url.merge(:view => true) : url
  end

  def comment_url_structure(comment, action = :edit)
    if comment.new_record?
      profile.url.merge(:page => path.split("/"), :controller => :comment, :action => :create)
    else
      profile.url.merge(:page => path.split("/"), :controller => :comment, :action => action || :edit, :id => comment.id)
    end
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

  def forum?
    false
  end

  def uploaded_file?
    false
  end

  def has_posts?
    false
  end

  named_scope :native_translations, :conditions => { :translation_of_id => nil }

  def translatable?
    false
  end

  def native_translation
    self.translation_of.nil? ? self : self.translation_of
  end

  def possible_translations
    possibilities = environment.locales.keys - self.native_translation.translations(:select => :language).map(&:language) - [self.native_translation.language]
    possibilities << self.language unless self.language_changed?
    possibilities
  end

  def known_language
    unless self.language.blank?
      errors.add(:language, N_('Language not supported by the environment.')) unless environment.locales.key?(self.language)
    end
  end

  def used_translation
    unless self.language.blank? or self.translation_of.nil?
      errors.add(:language, N_('Language is already used')) unless self.possible_translations.include?(self.language)
    end
  end

  def translation_must_have_language
    unless self.translation_of.nil?
      errors.add(:language, N_('Language must be choosen')) if self.language.blank?
    end
  end

  def native_translation_must_have_language
    unless self.translation_of.nil?
      errors.add_to_base(N_('A language must be choosen for the native article')) if self.translation_of.language.blank?
    end
  end

  def rotate_translations
    unless self.translations.empty?
      rotate = self.translations
      root = rotate.shift
      root.update_attribute(:translation_of_id, nil)
      root.translations = rotate
    end
  end

  def get_translation_to(locale)
    if self.language.nil? || self.language.blank? || self.language == locale
      self
    elsif self.native_translation.language == locale
      self.native_translation
    else
      self.native_translation.translations.first(:conditions => { :language => locale })
    end
  end

  def published?
    if self.published
      if self.parent && !self.parent.published?
        return false
      end
      true
    else
      false
    end
  end

  def self.folder_types
    ['Folder', 'Blog', 'Forum', 'Gallery']
  end

  def self.text_article_types
    ['TextArticle', 'TextileArticle', 'TinyMceArticle']
  end

  named_scope :published, :conditions => { :published => true }
  named_scope :folders, :conditions => { :type => folder_types}
  named_scope :no_folders, :conditions => ['type NOT IN (?)', folder_types]
  named_scope :galleries, :conditions => { :type => 'Gallery' }
  named_scope :images, :conditions => { :is_image => true }
  named_scope :text_articles, :conditions => [ 'articles.type IN (?)', text_article_types ]

  named_scope :more_popular, :order => 'hits DESC'
  named_scope :more_comments, :order => "comments_count DESC"
  named_scope :more_recent, :order => "created_at DESC"

  def self.display_filter(user, profile)
    return {:conditions => ['published = ?', true]} if !user
    {:conditions => ["  articles.published = ? OR
                        articles.last_changed_by_id = ? OR
                        articles.profile_id = ? OR
                        ?",
                        true, user.id, user.id, user.has_permission?(:view_private_content, profile)] }
  end

  def display_unpublished_article_to?(user)
    user == author || allow_view_private_content?(user) || user == profile ||
    user.is_admin?(profile.environment) || user.is_admin?(profile)
  end

  def display_to?(user = nil)
    if published?
      profile.display_info_to?(user)
    else
      if !user
        false
      else
        display_unpublished_article_to?(user)
      end
    end
  end

  def allow_post_content?(user = nil)
    user && (user.has_permission?('post_content', profile) || allow_publish_content?(user) && (user == author))
  end

  def allow_publish_content?(user = nil)
    user && user.has_permission?('publish_content', profile)
  end

  def allow_view_private_content?(user = nil)
    user && user.has_permission?('view_private_content', profile)
  end

  alias :allow_delete?  :allow_post_content?
  alias :allow_spread?  :allow_post_content?

  def allow_create?(user)
    allow_post_content?(user) || allow_publish_content?(user)
  end

  def allow_edit?(user)
    allow_post_content?(user) || user && allow_members_to_edit && user.is_member_of?(profile)
  end

  def moderate_comments?
    moderate_comments == true
  end

  def comments_updated
    solr_save
  end

  def accept_category?(cat)
    !cat.is_a?(ProductCategory)
  end

  def public?
    profile.visible? && profile.public? && published?
  end


  def copy(options = {})
    attrs = attributes.reject! { |key, value| ATTRIBUTES_NOT_COPIED.include?(key.to_sym) }
    attrs.merge!(options)
    self.class.create(attrs)
  end

  def copy!(options = {})
    attrs = attributes.reject! { |key, value| ATTRIBUTES_NOT_COPIED.include?(key.to_sym) }
    attrs.merge!(options)
    self.class.create!(attrs)
  end

  ATTRIBUTES_NOT_COPIED = [
    :id,
    :profile_id,
    :parent_id,
    :path,
    :slug,
    :updated_at,
    :created_at,
    :version,
    :lock_version,
    :type,
    :children_count,
    :comments_count,
    :hits,
  ]

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

  def event?
    false
  end

  def gallery?
    false
  end

  def tiny_mce?
    false
  end

  def author
    if versions.empty?
      last_changed_by
    else
      author_id = versions.first.last_changed_by_id
      Person.exists?(author_id) ? Person.find(author_id) : nil
    end
  end

  def author_name
    author ? author.name : (setting[:author_name] || _('Unknown'))
  end

  def author_url
    author ? author.url : nil
  end

  def author_id
    author ? author.id : nil
  end

  alias :active_record_cache_key :cache_key
  def cache_key(params = {}, the_profile = nil, language = 'en')
    active_record_cache_key+'-'+language +
      (allow_post_content?(the_profile) ? "-owner" : '') +
      (params[:npage] ? "-npage-#{params[:npage]}" : '') +
      (params[:year] ? "-year-#{params[:year]}" : '') +
      (params[:month] ? "-month-#{params[:month]}" : '')
  end

  def first_paragraph
    paragraphs = Hpricot(to_html).search('p')
    paragraphs.empty? ? '' : paragraphs.first.to_html
  end

  def lead
    abstract.blank? ? first_paragraph.html_safe : abstract.html_safe
  end

  def short_lead
    truncate sanitize_html(self.lead), :length => 170, :omission => '...'
  end

  def notifiable?
    false
  end

  def accept_uploads?
    self.parent && self.parent.accept_uploads?
  end

  def body_images_paths
    require 'uri'
    Hpricot(self.body.to_s).search('img[@src]').collect do |i|
      (self.profile && self.profile.environment) ? URI.join(self.profile.environment.top_url, URI.escape(i.attributes['src'])).to_s : i.attributes['src']
    end
  end

  def more_comments_label
    amount = self.comments_count
    {
      0 => _('no comments'),
      1 => _('one comment')
    }[amount] || _("%s comments") % amount

  end

  def more_popular_label
    amount = self.hits
    {
      0 => _('no views'),
      1 => _('one view')
    }[amount] || _("%s views") % amount

  end

  def more_recent_label
    _('Created at: ')
  end

  def activity
    ActionTracker::Record.find_by_target_type_and_target_id 'Article', self.id
  end

  def create_activity
    if is_trackable? && !image?
      save_action_for_verb 'create_article', [:name, :url, :lead, :first_image], Proc.new{}, :author
    end
  end

  def first_image
    img = Hpricot(self.lead.to_s).search('img[@src]').first || Hpricot(self.body.to_s).search('img').first
    img.nil? ? '' : img.attributes['src']
  end

  delegate :region, :region_id, :environment, :environment_id, :to => :profile, :allow_nil => true

  private

  def sanitize_tag_list
    sanitizer = HTML::FullSanitizer.new
    self.tag_list.names.map!{|i| strip_tag_name sanitizer.sanitize(i) }
  end

  def strip_tag_name(tag_name)
    tag_name.gsub(/[<>]/, '')
  end

  def sanitize_html(text)
    sanitizer = HTML::FullSanitizer.new
    sanitizer.sanitize(text)
  end

end
