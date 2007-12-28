module CmsHelper

  def link_to_new_article(mime_type)
    action = mime_type_to_action_name(mime_type) + '_new'
    button('new', _("New %s") % mime_type, :action => action, :parent_id => params[:parent_id])
  end

  def mime_type_to_action_name(mime_type)
    mime_type.gsub('/', '_').gsub('-', '')
  end

  def icon_for_article(article)
    icon = article.icon_name
    if (icon =~ /\//)
      icon
    else
      if File.exists?(File.join(RAILS_ROOT, 'public', 'images', 'icons-mime', "#{icon}.png"))
        "icons-mime/#{icon}.png"
      else
        "icons-mime/unknown.png"
      end
    end
  end

end
