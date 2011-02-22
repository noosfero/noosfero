module ArticleHelper

  def custom_options_for_article(article)
    @article = article
    content_tag('h4', _('Options')) +
    content_tag('div',
      content_tag(
        'div',
        check_box(:article, :published) +
        content_tag('label', _('This article must be published (visible to other people)'), :for => 'article_published')
      ) + (article.parent && article.parent.forum? && controller.action_name == 'new' ?
      hidden_field_tag('article[accept_comments]', 1) :
      content_tag(
        'div',
        check_box(:article, :accept_comments) +
        content_tag('label', (article.parent && article.parent.forum? ? _('This topic is opened for replies') : _('I want to receive comments about this article')), :for => 'article_accept_comments')
      )) +
      content_tag(
        'div',
        check_box(:article, :notify_comments) +
        content_tag('label', _('I want to receive a notification of each comment written by e-mail'), :for => 'article_notify_comments') +
        observe_field(:article_accept_comments, :function => "$('article_notify_comments').disabled = ! $('article_accept_comments').checked") 
      ) + (article.can_display_hits? ?
      content_tag(
        'div',
        check_box(:article, :display_hits) +
        content_tag('label', _('I want this article to display the number of hits it received'), :for => 'article_display_hits')
      ) : '')
    )
  end

  def cms_label_for_new_children
    _('New article')
  end

  def cms_label_for_edit
    _('Edit')
  end

end
