class BlogArchivesBlock < Block

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::AssetTagHelper
  include DatesHelper

  def self.description
    _('Blog posts')
  end

  def default_title
    _('Blog posts')
  end

  settings_items :blog_id, Integer

  def blog
    blog_id && owner.blogs.exists?(blog_id) ? owner.blogs.find(blog_id) : owner.blog
  end

  def visible_posts(person)
    #FIXME Performance issues with display_to. Must convert it to a scope.
    # Checkout this page for further information: http://noosfero.org/Development/ActionItem2705
    blog.posts.published.native_translations #.select {|post| post.display_to?(person)}
  end

  def content(args={})
    owner_blog = self.blog
    return nil unless owner_blog
    results = ''
    posts = visible_posts(args[:person])
    posts.except(:order).count(:all, :group => 'EXTRACT(YEAR FROM published_at)').sort_by {|year, count| -year.to_i}.each do |year, count|
      results << content_tag('li', content_tag('strong', "#{year} (#{count})"))
      results << "<ul class='#{year}-archive'>"
      posts.except(:order).count(:all, :conditions => ['EXTRACT(YEAR FROM published_at)=?', year], :group => 'EXTRACT(MONTH FROM published_at)').sort_by {|month, count| -month.to_i}.each do |month, count|
        month_name = gettext(MONTHS[month.to_i - 1])
        results << content_tag('li', link_to("#{month_name} (#{count})", owner_blog.url.merge(:year => year, :month => month)))
      end
      results << "</ul>"
    end
    block_title(title) +
    content_tag('ul', results, :class => 'blog-archives') +
    content_tag('div', link_to(_('Subscribe RSS Feed'), owner_blog.feed.url), :class => 'subscribe-feed')
  end

  def self.expire_on
      { :profile => [:article], :environment => [:article] }
  end
end
