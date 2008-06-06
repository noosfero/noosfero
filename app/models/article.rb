class Article < ActiveRecord::Base

  # xss_terminate plugin can't sanitize array fields
  before_save :sanitize_tag_list

  belongs_to :profile
  validates_presence_of :profile_id, :name, :slug, :path

  validates_uniqueness_of :slug, :scope => ['profile_id', 'parent_id'], :message => _('%{fn} (the code generated from the article name) is already being used by another article.')

  belongs_to :last_changed_by, :class_name => 'Person', :foreign_key => 'last_changed_by_id'

  has_many :comments, :dependent => :destroy

  has_and_belongs_to_many :categories

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
  def self.recent(limit)
    options = { :limit => limit, :conditions => { :advertise => true }, :order => 'created_at desc, articles.id desc' }
    self.find(:all, options)
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
  def to_html
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

  def url
    self.profile.url.merge(:page => path.split('/'))
  end

  def allow_children?
    true
  end

  def folder?
    false
  end

  def self.find_by_initial(initial)
    self.find(:all, :order => 'articles.name', :conditions => [ 'articles.name like (?) or articles.name like (?)', initial + '%', initial.upcase + '%'])
  end

  def display_to?(user)
    if self.profile.public_content
      true
    else
      if user.nil?
        false
      else
        (user == self.profile) || user.memberships.include?(self.profile)
      end
    end
  end

  def comments_updated
    ferret_update
  end

  private

  def sanitize_tag_list
    sanitizer = HTML::FullSanitizer.new
    self.tag_list.names.map!{|i| sanitizer.sanitize(i) }
  end

end
