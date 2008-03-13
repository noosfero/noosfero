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

  attr_reader :environment

  def select_categories(object_name)
    object = instance_variable_get("@#{object_name}")

    result = content_tag('h4', _('Categories'))
    environment.top_level_categories.each do |toplevel|
      toplevel.map_traversal do |cat|
        if cat.top_level?
          result << content_tag('h5', toplevel.name)
        else
          checkbox_id = "#{object_name}_#{cat.full_name.downcase.gsub(/\s+|\//, '_')}"
          result << content_tag('label', check_box_tag("#{object_name}[category_ids][]", cat.id, object.category_ids.include?(cat.id), :id => checkbox_id) + cat.full_name_without_leading(1), :for => checkbox_id)
        end
      end
    end

    content_tag('div', result)
  end

end
