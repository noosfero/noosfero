class Article < ActiveRecord::Base

  belongs_to :profile
  validates_presence_of :profile_id, :name, :slug, :path

  validates_uniqueness_of :slug, :scope => ['profile_id', 'parent_id'], :message => _('%{fn} (the code generated from the article name) is already being used by another article.')

  belongs_to :last_changed_by, :class_name => Person.name, :foreign_key => 'last_changed_by_id'

  has_many :comments

  acts_as_taggable  
  N_('Tag list')

  acts_as_filesystem

  acts_as_versioned

  acts_as_searchable :fields => [ :name, :abstract, :body, :tag_list ]

  # retrieves all articles belonging to the given +profile+ that are not
  # sub-articles of any other article.
  def self.top_level_for(profile)
    self.find(:all, :conditions => [ 'parent_id is null and profile_id = ?', profile.id ])
  end

  # retrieves the latest +limit+ articles in profile +profile+, sorted from the
  # most recent to the oldest.
  def self.recent(profile, limit)
    self.find(:all, :limit => limit, :order => 'created_on')
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

  def title
    name
  end

  def public_path(with_profile = true)
    elements = [path]
    if with_profile
      elements.unshift(profile.identifier)
    end
    "/" + elements.join('/')
  end

  def self.short_description
    if self == Article
      _('Article')
    else
      _('"%s" article') % self.article_type_name
    end
  end

  def self.description
    if self == Article
      _('An ordinary article')
    else
      _('An article of type "%s"') % self.article_type_name
    end
  end

  def self.article_type_name
    self.name.gsub(/article$/i, '')
  end

  def url
    self.profile.url + self.public_path(false)
  end

  def allow_children?
    true
  end

end
