module ContentViewerHelper

  include GetText

  def number_of_comments(article)
    n = article.comments.size
    if n == 0
     _('No comments yet')
    else
     n_('One comment', '%{comments} comments', n) % { :comments => n }
    end
  end

  def article_title(article, args = {})
    title = content_tag('h1', article.title, :class => 'title')
    if article.belongs_to_blog?
      unless args[:no_link]
        title = content_tag('h3', link_to(article.name, article.url), :class => 'title')
      end
      title << content_tag('span', _("%s, by %s") % [show_date(article.created_at), article.profile.name], :class => 'created-at')
    end
    title
  end

  def list_posts(articles)
    pagination = will_paginate(articles, {
      :param_name => 'npage',
      :page_links => false,
      :prev_label => _('Newer posts &raquo;'),
      :next_label => _('&laquo; Older posts')
    })
    articles.map{ |i| content_tag('div', display_post(i), :class => 'blog-post', :id => "post-#{i.id}") }.join("\n") +
      (pagination or '')
  end

  def display_post(article)
    article_title(article) + content_tag('p', article.to_html) +
    content_tag('p', link_to( number_of_comments(article), article.url.merge(:form => 'opened', :anchor => 'comment_form') ), :class => 'metadata')
  end

  def article_to_html(article)
    if article.blog?
      children = if article.filter and article.filter[:year] and article.filter[:month]
        filter_date = DateTime.parse("#{article.filter[:year]}-#{article.filter[:month]}-01")
        article.posts.paginate :page => params[:npage], :per_page => article.posts_per_page, :conditions => [ 'created_at between ? and ?', filter_date, filter_date + 1.month - 1.day ]
      else
        article.posts.paginate :page => params[:npage], :per_page => article.posts_per_page
      end
      article.to_html + (children.compact.empty? ? content_tag('em', _('(no posts)')) : list_posts(children))
    else
      article.to_html
    end
  end

end
