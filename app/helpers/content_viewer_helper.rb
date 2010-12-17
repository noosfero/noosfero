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
      comments = args[:no_comments] ? '' : (("- %s") % link_to_comments(article))
      title << content_tag('span', _("%s, by %s %s") % [show_date(article.published_at), link_to(article.author_name, article.author.url), comments], :class => 'created-at')
    end
    title
  end

  def link_to_comments(article, args = {})
    link_to( number_of_comments(article), article.url.merge(:anchor => 'comments_list') )
  end

  def image_label(image)
    text = image.abstract || image.title
    text && (text.first(40) + (text.size > 40 ? '…' : ''))
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

end
