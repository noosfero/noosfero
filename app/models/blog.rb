class Blog < Folder

  has_many :posts, :class_name => 'Article', :foreign_key => 'parent_id', :source => :children, :conditions => [ 'type != ?', 'RssFeed' ], :order => 'created_at DESC'

  attr_accessor :feed_attrs
  attr_accessor :filter

  after_create do |blog|
    blog.children << RssFeed.new(:name => 'feed', :profile => blog.profile, :include => 'parent_and_children')
    blog.feed = blog.feed_attrs
  end

  settings_items :posts_per_page, :type => :integer, :default => 20
  settings_items :title, :type => :string, :default => _('My blog')

  def initialize(*args)
    super(*args)
    self.name = 'blog'
  end

  def self.short_description
    _('Blog')
  end

  def self.description
    _('A blog, inside which you can put other articles.')
  end

  # FIXME isn't this too much including just to be able to generate some HTML?
  include ActionView::Helpers::TagHelper
  def to_html
    content_tag('div', body) + tag('hr')
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
    if self.feed
      self.feed.update_attributes(attrs)
    else
      self.feed_attrs = attrs
    end
  end

end
