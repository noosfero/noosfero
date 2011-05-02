module ContentViewerHelper

  include BlogHelper
  include ForumHelper

  def number_of_comments(article)
    n = article.comments.size
    if n == 0
     _('No comments yet')
    else
     n_('One comment', '%{comments} comments', n) % { :comments => n }
    end
  end

  def article_title(article, args = {})
    title = article.display_title if article.kind_of?(UploadedFile) && article.image?
    title = article.title if title.blank?
    title = content_tag('h1', h(title), :class => 'title')
    if article.belongs_to_blog?
      unless args[:no_link]
        title = content_tag('h1', link_to(article.name, article.url), :class => 'title')
      end
      comments = ''
      unless args[:no_comments] || !article.accept_comments
        comments = (" - %s") % link_to_comments(article)
      end
      title << content_tag('span',
        content_tag('span', show_date(article.published_at), :class => 'date') +
        content_tag('span', [_(", by %s") % link_to(article.author_name, article.author.url)], :class => 'author') +
        content_tag('span', comments, :class => 'comments'),
        :class => 'created-at'
      )
    end
    title
  end

  def link_to_comments(article, args = {})
    return '' unless article.accept_comments?
    link_to(number_of_comments(article), article.url.merge(:anchor => 'comments_list') )
  end

  def article_translations(article)
    unless article.native_translation.translations.empty?
      links = (article.native_translation.translations + [article.native_translation]).map do |translation|
        { Noosfero.locales[translation.language] => { :href => url_for(translation.url) } }
      end
      content_tag(:div, link_to(_('Translations'), '#',
                                :onclick => "toggleSubmenu(this, '#{_('Translations')}', #{links.to_json}); return false",
                                :class => 'article-translations-menu simplemenu-trigger up'),
                  :class => 'article-translations')
    end
  end

  def addthis_facebook_url(article)
    "http://www.facebook.com/sharer.php?s=100&p[title]=%{title}&p[summary]=%{summary}&p[url]=%{url}&p[images][0]=%{image}" % {
      :title => CGI.escape(article.title),
      :url => CGI.escape(url_for(article.url)),
      :summary => CGI.escape(truncate(strip_tags(article.body.to_s), 300)),
      :image => CGI.escape(article.body_images_paths.first.to_s)
    }
  end

end
