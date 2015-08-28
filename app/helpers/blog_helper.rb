module BlogHelper

  include ArticleHelper

  def custom_options_for_article(article,tokenized_children)
    @article = article
    hidden_field_tag('article[published]', 1) +
    hidden_field_tag('article[accept_comments]', 0) +
    visibility_options(article,tokenized_children) +
    content_tag('h4', _('Visualization of posts')) +
    content_tag(
      'div',
      check_box(:article, :display_preview) +
      content_tag('label', _('I want to display the preview of posts before the text'), :for => 'article_display_preview')
    )
  end

  def cms_label_for_new_children
    _('New post')
  end

  def cms_label_for_edit
    _('Configure blog')
  end

  def list_posts(articles, conf = { format: 'full', paginate: true })
    pagination = will_paginate(articles, {
      :param_name => 'npage',
      :previous_label => _('&laquo; Newer posts'),
      :next_label => _('Older posts &raquo;'),
      :params => {:action=>"view_page",
                  :page=>articles.first.parent.path.split('/'),
                  :controller=>"content_viewer"}
    }) if articles.present? && conf[:paginate]
    content = []
    artic_len = articles.length
    articles.each_with_index{ |art,i|
      css_add = [ 'blog-post', 'position-'+(i+1).to_s() ]
      position = (i%2 == 0) ? 'odd-post' : 'even-post'
      css_add << 'first' if i == 0
      css_add << 'last'  if i == (artic_len-1)
      css_add << 'not-published' if !art.published?
      css_add << position
      content << (content_tag 'div', id: "post-#{art.id}", class: css_add do
        content_tag 'div', class: position + '-inner blog-post-inner' do
          display_post(art, conf[:format]).html_safe +
          '<br style="clear:both"/>'.html_safe
        end
      end)
    }
    content.join("\n<hr class='sep-posts'/>\n") + (pagination or '')
  end

  def display_post(article, format = 'full')
    no_comments = (format == 'full' || format == 'compact' ) ? false : true
    title = article_title(article, :no_comments => no_comments)
    method = "display_#{format.split('+')[0]}_format"
    html = send(method, FilePresenter.for(article)).html_safe
    if format.split('+')[1] == 'pic'
      img = article.first_image
      if img.blank?
        '<div class="post-pic empty"></div>'
      else
        '<div class="post-pic" style="background-image:url('+img+')"></div>'
      end
    end.to_s + title + html
  end

  def display_compact_format(article)
    render :file => 'content_viewer/_display_compact_format',
           :locals => { :article => article, :format => "compact" }
  end

  def display_full_format(article)
    html = article_to_html(article)
    html = content_tag('p', html) if ! html.include?('</p>')
    html
  end

end
