module ContentViewerHelper

  include BlogHelper
  include ForumHelper

  def display_number_of_comments(n)
    base_str = "<span class='comment-count hide'>#{n}</span>"
    amount_str = n == 0 ? _('no comments yet') : (n == 1 ? _('One comment') : _('%s comments') % n)
    base_str + "<span class='comment-count-write-out'>#{amount_str}</span>"
  end

  def number_of_comments(article)
    display_number_of_comments(article.comments_count - article.spam_comments_count.to_i)
  end

  def article_title(article, args = {})
    title = article.title
    title = content_tag('h1', h(title), :class => 'title')
    if article.belongs_to_blog? || article.belongs_to_forum?
      unless args[:no_link]
        title = content_tag('h1', link_to(article.name, article.url), :class => 'title')
      end
      comments = ''
      unless args[:no_comments] || !article.accept_comments
        comments = (" - %s") % link_to_comments(article)
      end
      title << content_tag('span',
        content_tag('span', show_date(article.published_at), :class => 'date') +
        content_tag('span', _(", by %s") % (article.author ? link_to(article.author_name, article.author_url) : article.author_name), :class => 'author') +
        content_tag('span', comments, :class => 'comments'),
        :class => 'created-at'
      )
    end
    title
  end

  def link_to_comments(article, args = {})
    return '' unless article.accept_comments?
    reference_to_article number_of_comments(article), article, 'comments_list'
  end

  def article_translations(article)
    unless article.native_translation.translations.empty?
      links = (article.native_translation.translations + [article.native_translation]).map do |translation|
        { article.environment.locales[translation.language] => { :href => url_for(translation.url) } }
      end
      content_tag(:div, link_to(_('Translations'), '#',
                                :onmouseover => "toggleSubmenu(this, '#{_('Translations')}', #{CGI::escape_html(links.to_json)}); return false",
                                :class => 'article-translations-menu simplemenu-trigger up'),
                  :class => 'article-translations')
    end
  end

  def addthis_image_tag
    if File.exists?(Rails.root.join('public', theme_path, 'images', 'addthis.gif'))
      image_tag(File.join(theme_path, 'images', 'addthis.gif'), :border => 0, :alt => '')
    else
      image_tag("/images/bt-bookmark.gif", :width => 53, :height => 16, :border => 0, :alt => '')
    end
  end

end
