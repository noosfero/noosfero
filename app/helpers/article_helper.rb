module ArticleHelper

  def custom_options_for_article(article)
    @article = article
    content_tag('h4', _('Options')) +
    content_tag('div',
      check_box(:article, :published) +
      content_tag('label', _('Published'), :for => 'article_published') +
      check_box(:article, :accept_comments) +
      content_tag('label', _('Accept Comments'), :for => 'article_accept_comments')
    )
  end

end
