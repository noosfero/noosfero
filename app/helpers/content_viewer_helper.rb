module ContentViewerHelper

  include BlogHelper

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
      title << content_tag('span', _("%s, by %s - %s") % [show_date(article.published_at), link_to(article.author.name, article.author.url), link_to_comments(article)], :class => 'created-at')
    end
    title
  end

  def link_to_comments(article)
    link_to( number_of_comments(article), article.url.merge(:anchor => 'comments_list') )
  end

  def image_label(image)
    text = image.title || image.abstract
    text && (text.first(40) + (text.size > 40 ? '…' : ''))
  end

end
