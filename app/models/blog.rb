class Blog < Folder

  acts_as_having_posts

  #FIXME This should be used until there is a migration to fix all blogs that
  # already have folders inside them
  def posts_with_no_folders
    posts_without_no_folders.no_folders
  end
  alias_method_chain :posts, :no_folders

  def self.short_description
    _('Blog')
  end

  def self.description
    _('A blog, inside which you can put other articles.')
  end

  # FIXME isn't this too much including just to be able to generate some HTML?
  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/blog_page'
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

  def validate
    unless self.external_feed_data.nil?
      if self.external_feed(true) && self.external_feed.id == self.external_feed_data[:id].to_i
        self.external_feed.attributes = self.external_feed_data
      else
        self.build_external_feed(self.external_feed_data)
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
  validates_inclusion_of :visualization_format, :in => [ 'full', 'short' ], :if => :visualization_format

  settings_items :display_posts_in_current_language, :type => :boolean, :default => true

  alias :display_posts_in_current_language? :display_posts_in_current_language

end
