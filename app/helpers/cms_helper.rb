module CmsHelper

  def link_to_edit_article(article)
    button('edit', _("Edit"), url_for_edit_article(article))
  end

  def url_for_edit_article(article)
    action = article.mime_type.gsub('/', '_') + '_edit'
    url_for(:action => action, :id => article.id)
  end

  def link_to_new_article(mime_type)
    action = mime_type.gsub('/', '_') + '_new'
    button('new', _("New %s") % mime_type, :action => action, :parent_id => params[:parent_id])
  end

end
