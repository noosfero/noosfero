module ArticleHelper

  def custom_options_for_article(article)
    @article = article
    content_tag('h4', _('Options')) +
    content_tag('div',
      check_box(:article, :published) +
      content_tag('label', _('Published'), :for => 'article_published') +
      check_box(:article, :accept_comments) +
      content_tag('label', _('Accept Comments'), :for => 'article_accept_comments') +
      check_box(:article, :notify_comments) +
      content_tag('label', _('Notify Comments'), :for => 'article_notify_comments')
    ) + observe_field(:article_accept_comments, :function => "$('article_notify_comments').disabled = ! $('article_accept_comments').checked")
  end

  def cms_label_for_new_children
    _('New article')
  end

  def cms_label_for_edit
    _('Edit')
  end

end
