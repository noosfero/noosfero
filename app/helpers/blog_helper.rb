module BlogHelper

  def custom_options_for_article(article)
    @article = article
    hidden_field_tag('article[published]', 1) +
    hidden_field_tag('article[accept_comments]', 0)
  end

  def cms_label_for_new_children
    _('New post')
  end

  def cms_label_for_edit
    _('Edit blog')
  end

  def list_posts(user, articles)
    pagination = will_paginate(articles, {
      :param_name => 'npage',
      :prev_label => _('&laquo; Newer posts'),
      :next_label => _('Older posts &raquo;')
    })
    content = []
    articles.map{ |i|
      css_add = ''
      if i.published? || (user==i.profile)
        css_add = '-not-published' if !i.published?
        content << content_tag('div', display_post(i), :class => 'blog-post' + css_add, :id => "post-#{i.id}")
      end
    }
    content.join("\n") + (pagination or '')
  end

  def display_post(article)
    article_title(article) + content_tag('p', article.to_html) +
    content_tag('p', link_to( number_of_comments(article), article.url.merge(:form => 'opened', :anchor => 'comment_form') ), :class => 'metadata')
  end
end
