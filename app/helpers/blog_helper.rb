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

end
