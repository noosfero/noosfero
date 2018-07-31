module ContentViewerHelper

  include BlogHelper
  include ForumHelper
  include DatesHelper

  def display_number_of_comments(n)
    base_str = "<span class='comment-count hide'>#{n}</span>"
    amount_str = n == 0 ? _('no comments yet') : (n == 1 ? _('One comment') : _('%s comments') % n)
    base_str += "<span class='comment-count-write-out'>#{amount_str}</span>"
    base_str.html_safe
  end

  def number_of_comments(article)
    display_number_of_comments(article.comments_count - article.spam_comments_count.to_i)
  end

  def article_title(article, args = {})
    title = article.title
    title = content_tag('h1', h(title), :class => 'title')
    if article.belongs_to_blog? || article.belongs_to_forum?
      unless args[:no_link]
        title = content_tag('h1', link_to(article.title, url_for(article.view_url)), :class => 'title')
      end
      comments = ''
      unless args[:no_comments] || !article.accept_comments
        comments = (" - %s").html_safe % link_to_comments(article)
      end
      date_format = show_with_right_format_date article
      title << content_tag('span',
        date_format +
        content_tag('span', _(", by %s").html_safe % (article.author ? link_to(article.author_name, article.author_url) : article.author_name), :class => 'author') +
        content_tag('span', comments, :class => 'comments'),
        :class => 'publishing-info'
      )
      title << content_tag(:div,
        content_tag(:span, '', :class => 'ui-icon ui-icon-locked') +
        content_tag(:span, _("This is a private content"), :class => 'alert-message'),
        :class => 'not-published alert-text'
      ) unless article.published?
    end
    title
  end

  def show_with_right_format_date article
    date_format = article.environment.date_format
    use_numbers = false
    year = true
    left_time = false
    if date_format ==  'numbers_with_year'
      use_numbers = true
    elsif date_format == 'numbers'
      use_numbers = true
      year = false
    elsif date_format == 'month_name'
      year = false
    elsif date_format == 'past_time'
      left_time = true
    end
    content_tag('span', show_time(article.published_at, use_numbers , year, left_time), :class => 'date')
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
                                :onmouseover => "toggleSubmenu(this, '#{_('Translations')}', #{links.to_json}); return false",
                                :class => 'article-translations-menu simplemenu-trigger up'),
                  :class => 'article-translations')
    end
  end

  def addthis_image_tag
    if File.exists?(Rails.root.join('public', theme_path, 'images', 'addthis.gif'))
      image_tag(File.join(theme_path, 'images', 'addthis.gif'), :border => 0, :alt => _('Share this page'))
    else
      image_tag("/images/bt-bookmark.gif", :width => 53, :height => 16, :border => 0, :alt => _('Share this page'))
    end
  end

end
