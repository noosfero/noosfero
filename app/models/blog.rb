class Blog < Folder

  has_many :posts, :class_name => 'Article', :foreign_key => 'parent_id', :source => :children, :conditions => [ 'type != ?', 'RssFeed' ], :order => 'published_at DESC, id DESC'

  attr_accessor :feed_attrs

  after_create do |blog|
    blog.children << RssFeed.new(:name => 'feed', :profile => blog.profile)
    blog.feed = blog.feed_attrs
  end

  settings_items :posts_per_page, :type => :integer, :default => 5

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

  def feed
    self.children.find(:first, :conditions => {:type => 'RssFeed'})
  end

  def feed=(attrs)
    if attrs
      if self.feed
        self.feed.update_attributes(attrs)
      else
        self.feed_attrs = attrs
      end
    end
    self.feed
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

  def name=(value)
    self.set_name(value)
    if self.slug.blank?
      self.slug = self.name.to_slug
    else
      self.slug = self.slug.to_slug
    end
  end

  settings_items :visualization_format, :type => :string, :default => 'full'
  validates_inclusion_of :visualization_format, :in => [ 'full', 'short' ], :if => :visualization_format


end
