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
    _('Configure blog')
  end

  def list_posts(articles, format = 'full')
    pagination = will_paginate(articles, {
      :param_name => 'npage',
      :prev_label => _('&laquo; Newer posts'),
      :next_label => _('Older posts &raquo;')
    })
    content = []
    artic_len = articles.length
    articles.each_with_index{ |art,i|
      css_add = [ 'position-'+(i+1).to_s() ]
      position = (i%2 == 0) ? 'odd-post' : 'even-post'
      css_add << 'first' if i == 0
      css_add << 'last'  if i == (artic_len-1)
      css_add << 'not-published' if !art.published?
      css_add << position + '-inner'
      content << content_tag('div',
                             content_tag('div',
                                         display_post(art, format) + '<br style="clear:both"/>',
                                         :class => 'blog-post ' + css_add.join(' '),
                                         :id => "post-#{art.id}"), :class => position
                            )
    }
    content.join("\n<hr class='sep-posts'/>\n") + (pagination or '')
  end

  def display_post(article, format = 'full')
    no_comments = (format == 'full') ? false : true
    html = send("display_#{format}_format", article)

    article_title(article, :no_comments => no_comments) + html
  end

  def display_short_format(article)
    html = content_tag('div',
             article.lead +
             content_tag('div',
               link_to_comments(article) +
               link_to( _('Read more'), article.url),
               :class => 'read-more'),
             :class => 'short-post'
           )
    html
  end

  def display_full_format(article)
    html = article_to_html(article)
    html = content_tag('p', html) if ! html.include?('</p>')
    html
  end

end
