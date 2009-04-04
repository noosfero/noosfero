class BlogArchivesBlock < Block

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  include ActionView::Helpers::AssetTagHelper
  include DatesHelper

  def self.description
    _('List posts of your blog')
  end

  def default_title
    _('Blog posts')
  end

  def content
    return nil unless owner.has_blog?
    results = ''
    posts = owner.blog.posts
    posts.group_by {|i| i.published_at.year }.sort_by { |year,count| -year }.each do |year, results_by_year|
      results << content_tag('li', content_tag('strong', "#{year} (#{results_by_year.size})"))
      results << "<ul class='#{year}-archive'>"
      results_by_year.group_by{|i| [ ('%02d' % i.published_at.month()), gettext(MONTHS[i.published_at.month() - 1])]}.sort.each do |month, results_by_month|
        results << content_tag('li', link_to("#{month[1]} (#{results_by_month.size})", owner.generate_url(:controller => 'content_viewer', :action => 'view_page', :page => [owner.blog.path, year, month[0]])))
      end
      results << "</ul>"
    end
    block_title(title) +
    content_tag('ul', results, :class => 'blog-archives') +
    content_tag('div', link_to(_('Subscribe RSS Feed'), owner.blog.feed.url), :class => 'subscribe-feed')
  end

end
