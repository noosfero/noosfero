class Blog < Folder

  attr_accessible :visualization_format

  acts_as_having_posts
  include PostsLimit

  #FIXME This should be used until there is a migration to fix all blogs that
  # already have folders inside them
  def posts_with_no_folders
    posts_without_no_folders.no_folders(profile)
  end
  alias_method_chain :posts, :no_folders

  def self.type_name
    _('Blog')
  end

  def self.short_description
    _('Blog')
  end

  def self.description
    _('A blog, inside which you can put other articles.')
  end

  # FIXME isn't this too much including just to be able to generate some HTML?
  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    me = self
    proc do
      render :file => 'content_viewer/blog_page', :locals => { :blog=>me, :inside_block=>options[:inside_block] }
    end
  end

  def folder?
    true
  end

  def blog?
    true
  end

  has_one :external_feed, :foreign_key => 'blog_id', :dependent => :destroy

  attr_accessor :external_feed_data
  def external_feed_builder=(efeed)
    self.external_feed_data = efeed
  end

  validate :prepare_external_feed

  def prepare_external_feed
    unless self.external_feed_data.nil?
      if self.external_feed(true) && self.external_feed.id == self.external_feed_data[:id].to_i
        self.external_feed.attributes = self.external_feed_data.except(:id)
      else
        self.build_external_feed(self.external_feed_data, :without_protection => true)
      end
      self.external_feed.valid?
      self.external_feed.errors.delete(:blog_id) # dont validate here relation: external_feed <-> blog
      self.external_feed.errors.each do |attr,msg|
        self.errors.add(attr, msg)
      end
    end
  end

  after_save do |blog|
    if blog.external_feed
      blog.external_feed.save
    end
  end

  def self.icon_name(article = nil)
    'blog'
  end

  settings_items :visualization_format, :type => :string, :default => 'full'
  validates_inclusion_of :visualization_format,
                         :in => [ 'full', 'short', 'short+pic', 'compact'],
                         :if => :visualization_format

  settings_items :display_posts_in_current_language,
                 :type => :boolean, :default => false

  alias :display_posts_in_current_language? :display_posts_in_current_language

  def empty?
    posts.empty?
  end

  def last_posts(limit=3)
    posts.where("type != 'RssFeed'").order(:updated_at).limit(limit)
  end

  def total_number_of_posts(group_by, year = nil)
    case group_by
      when :by_year
        posts.published.native_translations
          .except(:order)
          .group('EXTRACT(YEAR FROM published_at)')
          .count
          .sort_by{ |year, count| -year.to_i }
      when :by_month
        posts.published.native_translations
          .except(:order)
          .where('EXTRACT(YEAR FROM published_at)=?', year.to_i)
          .group('EXTRACT(MONTH FROM published_at)')
          .count
          .sort_by {|month, count| -month.to_i}
    end
  end
end
