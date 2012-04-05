module ForumHelper

  def cms_label_for_new_children
    _('New discussion topic')
  end

  def cms_label_for_edit
    _('Configure forum')
  end

  def list_forum_posts(articles)
    pagination = will_paginate(articles, {
      :param_name => 'npage',
      :previous_label => _('&laquo; Newer posts'),
      :next_label => _('Older posts &raquo;')
    })
    content = [content_tag('tr',
                           content_tag('th', _('Discussion topic')) +
                           content_tag('th', _('Posts')) +
                           content_tag('th', _('Last post'))
                          )
              ]
    artic_len = articles.length
    articles.each_with_index{ |art,i|
      css_add = [ 'position-'+(i+1).to_s() ]
      position = (i%2 == 0) ? 'odd-post' : 'even-post'
      css_add << 'first' if i == 0
      css_add << 'last'  if i == (artic_len-1)
      css_add << 'not-published' if !art.published?
      css_add << position
      content << content_tag('tr',
                             content_tag('td', link_to(art.title, art.url)) +
                             content_tag('td', link_to(art.comments.count, art.url.merge(:anchor => 'comments_list'))) +
                             content_tag('td', last_topic_update(art)),
                             :class => 'forum-post ' + css_add.join(' '),
                             :id => "post-#{art.id}"
                            )
    }
    content_tag('table', content) + (pagination or '')
  end

  def last_topic_update(article)
    info = article.info_from_last_update
    if info[:author_url]
      time_ago_as_sentence(info[:date]) + ' ' + _('ago') + ' ' + _('by') + ' ' + link_to(info[:author_name], info[:author_url])
    else
      time_ago_as_sentence(info[:date]) + ' ' + _('ago') + ' ' + _('by') + ' ' + info[:author_name]
    end
  end

end
