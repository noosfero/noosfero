module BlogHelper

  include ArticleHelper

  def custom_options_for_article(article,tokenized_children)
    @article = article
    hidden_field_tag('article[published]', 1) +
    hidden_field_tag('article[accept_comments]', 0) +
    visibility_options(article,tokenized_children)
  end

  def cms_label_for_new_children
    _('New post')
  end

  def cms_label_for_edit
    _('Configure blog')
  end

  def list_posts(articles, format = 'full', paginate = true)
    pagination = will_paginate(articles, {
      :param_name => 'npage',
      :previous_label => _('&laquo; Newer posts'),
      :next_label => _('Older posts &raquo;'),
      :params => {:action=>"view_page", :page=>articles.first.parent.path.split('/'), :controller=>"content_viewer"}
    }) if articles.present? && paginate
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
                                         display_post(art, format).html_safe + '<br style="clear:both"/>'.html_safe,
                                         :class => 'blog-post ' + css_add.join(' '),
                                         :id => "post-#{art.id}"), :class => position
                            )
    }
    content.join("\n<hr class='sep-posts'/>\n") + (pagination or '')
  end

  def display_post(article, format = 'full')
    no_comments = (format == 'full') ? false : true
    title = article_title(article, :no_comments => no_comments)
    html = send("display_#{format}_format", FilePresenter.for(article)).html_safe
    title + html
  end

  def display_full_format(article)
    html = article_to_html(article)
    html = content_tag('p', html) if ! html.include?('</p>')
    html
  end

end
