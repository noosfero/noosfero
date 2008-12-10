module CmsHelper

  def link_to_new_article(mime_type)
    action = mime_type_to_action_name(mime_type) + '_new'
    button('new', _("New %s") % mime_type, :action => action, :parent_id => params[:parent_id])
  end

  def mime_type_to_action_name(mime_type)
    mime_type.gsub('/', '_').gsub('-', '')
  end

  attr_reader :environment

  def options_for_article(article)
    article_helper = helper_for_article(article)
    article_helper.custom_options_for_article(article)
  end

end
