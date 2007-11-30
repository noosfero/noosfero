module CmsHelper

  def link_to_edit_article(article)
    button('edit', _("Edit"), url_for_edit_article(article))
  end

  def url_for_edit_article(article)
    action = mime_type_to_action_name(article.mime_type) + '_edit'
    url_for(:action => action, :id => article.id)
  end

  def link_to_new_article(mime_type)
    action = mime_type_to_action_name(mime_type) + '_new'
    button('new', _("New %s") % mime_type, :action => action, :parent_id => params[:parent_id])
  end

  def mime_type_to_action_name(mime_type)
    mime_type.gsub('/', '_').gsub('-', '')
  end

end
