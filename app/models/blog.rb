class Blog < Folder

  has_many :posts, :class_name => 'Article', :foreign_key => 'parent_id', :source => :children, :conditions => [ 'type != ?', 'RssFeed' ], :order => 'created_at DESC'

  attr_accessor :feed_attrs
  attr_accessor :filter

  after_create do |blog|
    blog.children << RssFeed.new(:name => 'feed', :profile => blog.profile, :feed_item_description => 'body')
    blog.feed = blog.feed_attrs
  end

  settings_items :posts_per_page, :type => :integer, :default => 20
  settings_items :title, :type => :string, :default => N_('Blog')

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
  def to_html(options = {})
    posts_list(options[:page])
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

  def posts_list(npage)
    article = self
    children = if filter and filter[:year] and filter[:month]
                filter_date = DateTime.parse("#{filter[:year]}-#{filter[:month]}-01")
                posts.paginate :page => npage, :per_page => posts_per_page, :conditions => [ 'created_at between ? and ?', filter_date, filter_date + 1.month - 1.day ]
              else
                posts.paginate :page => npage, :per_page => posts_per_page
              end
    lambda do
      render :file => 'content_viewer/blog_page', :locals => {:article => article, :children => children}
    end
  end
end
