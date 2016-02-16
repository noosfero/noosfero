class RssFeed < Article

  attr_accessible :limit, :enabled, :language, :include, :feed_item_description

  def self.type_name
    _('RssFeed')
  end

  # i dont know why before filter dont work here
  def initialize(*args)
    super(*args)
    self.advertise = false
  end

  # store setting in body
  serialize :body, Hash

  def body
    self[:body] ||= {}
  end
  alias :settings :body

  def feed_item_description
    self.body[:feed_item_description]
  end

  def feed_item_description=(feed_item_description)
    self.body[:feed_item_description] = feed_item_description
  end

  settings_items :limit, :type => :integer, :default => 10

  def limit_with_body_change=(value)
    #UPGRADE Leandro: I add this line to save the serialize attribute
    self.body_will_change!
    self.limit_without_body_change= value
  end

  alias_method_chain :limit=, :body_change

  # FIXME this should be validates_numericality_of, but Rails 2.0.2 does not
  # support validates_numericality_of with virtual attributes
  validates_format_of :limit, :with => /\d+/, :if => :limit

  # determinates what to include in the feed. Possible values are +:all+
  # (include everything from the profile) and :parent_and_children (include
  # only articles that are siblings of the feed).
  #
  # The feed itself is never included.
  def include
    settings[:include]
  end
  def include=(value)
    settings[:include] = value
  end
  validates_inclusion_of :include, :in => [ 'all', 'parent_and_children' ], :if => :include

  # TODO
  def to_html(options = {})
    ""
  end

  # RSS feeds have type =text/xml=.
  def mime_type
    'text/xml'
  end

  include Rails.application.routes.url_helpers
  def fetch_articles
    if parent && parent.has_posts?
      language = self.language.blank? ? {} : { :language => self.language }
      return parent.posts.where({published: true}.merge language).limit(self.limit).order('id desc')
    end

    articles =
      if (self.include == 'parent_and_children') && self.parent
        self.parent.map_traversal
      else
        profile.last_articles(self.limit)
      end
  end
  def data
    articles = fetch_articles.select { |a| a != self }
    FeedWriter.new.write(
      articles,
      :title => _("%s's RSS feed") % (self.profile.name),
      :description => _("%s's content published at %s") % [self.profile.name, self.profile.environment.name],
      :link => url_for(self.profile.url)
    )
  end

  def published?
    if self.parent
      self.parent.published?
    else
      self.published
    end
  end

  def self.short_description
    _('RSS Feed')
  end

  def self.description
    _('Provides a news feed of your more recent articles.')
  end

  def self.icon_name(article = nil)
    'rss-feed'
  end

  def can_display_hits?
    false
  end

end
