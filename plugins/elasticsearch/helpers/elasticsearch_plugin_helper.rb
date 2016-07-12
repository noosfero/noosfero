module ElasticsearchPluginHelper

  def render_categories(collection, selected_collections)
    content_tag :ul, class: "category-ident" do
      if collection.respond_to? :each
        collection.collect do |item|
          concat ("<li>".html_safe)
          concat (check_box_tag(item.name, item.id, selected_collections.include?(item.id.to_s)) )
          concat (label_tag item.name)
          concat (render_categories(item.children, selected_collections)) if item.children_count > 0
          concat ("</li>".html_safe)
        end
      else
        check_box_tag collection.name, collection.id, selected_collections.include?(collection.id)
        label_tag collection.name
      end
    end
  end

end
