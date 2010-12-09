class BlogArchivesBlock < Block

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
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
    blog_id ? owner.blogs.find(blog_id) : owner.blog
  end

  def content
    owner_blog = self.blog
    return nil unless owner_blog
    results = ''
    owner_blog.posts.native_translations.group_by {|i| i.published_at.year }.sort_by { |year,count| -year }.each do |year, results_by_year|
      results << content_tag('li', content_tag('strong', "#{year} (#{results_by_year.size})"))
      results << "<ul class='#{year}-archive'>"
      results_by_year.group_by{|i| [ ('%02d' % i.published_at.month()), gettext(MONTHS[i.published_at.month() - 1])]}.sort.reverse.each do |month, results_by_month|
        results << content_tag('li', link_to("#{month[1]} (#{results_by_month.size})", owner_blog.url.merge(:year => year, :month => month[0])))
      end
      results << "</ul>"
    end
    block_title(title) +
    content_tag('ul', results, :class => 'blog-archives') +
    content_tag('div', link_to(_('Subscribe RSS Feed'), owner_blog.feed.url), :class => 'subscribe-feed')
  end

end
