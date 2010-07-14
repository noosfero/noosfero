module ManageProductsHelper

  def remote_function_to_update_categories_selection(container_id, options = {})
    remote_function({
      :update => container_id,
      :url => { :action => "categories_for_selection" },
      :loading => "loading('hierarchy_navigation', '#{ _('loading…') }'); loading('#{container_id}', '&nbsp;')",
      :complete => "loading_done('hierarchy_navigation'); loading_done('#{container_id}')"
    }.merge(options))
  end

  def hierarchy_category_item(category, make_links, title = nil)
    title ||= category.name
    if make_links
      link_to(title, '#',
        :title => title,
        :onclick => remote_function_to_update_categories_selection("categories_container_level#{ category.level + 1 }",
          :with => "'category_id=#{ category.id }'"
        )
      )
    else
      title
    end
  end

  def hierarchy_category_navigation(current_category, options = {})
    hierarchy = []
    if current_category
      hierarchy << current_category.name
      count_chars = current_category.name.length
      ancestors = current_category.ancestors
      toplevel = ancestors.pop
      if toplevel
        count_chars += toplevel.name.length
      end
      ancestors.each do |category|
        if count_chars > 60
          hierarchy << hierarchy_category_item(category, options[:make_links], '( … )')
          break
        else
          hierarchy << hierarchy_category_item(category, options[:make_links])
        end
        count_chars += category.name.length
      end
      if toplevel
        hierarchy << hierarchy_category_item(toplevel, options[:make_links])
      end
    end
    hierarchy.reverse.join(options[:separator] || ' &rarr; ')
  end

  def options_for_select_categories(categories)
    categories.sort_by{|cat| cat.name.transliterate}.map do |category|
      "<option value='#{category.id}'>#{category.name + (category.leaf? ? '': ' &raquo;')}</option>"
    end.join("\n")
  end

  def select_for_categories(categories, level = 0)
    if categories.empty?
      content_tag('div', '', :id => 'no_subcategories')
    else
      select_tag('category_id',
        options_for_select_categories(categories),
        :size => 10,
        :onchange => remote_function_to_update_categories_selection("categories_container_level#{ level + 1 }", :with => "'category_id=' + this.value")
      ) +
      content_tag('div', '', :class => 'categories_container', :id => "categories_container_level#{ level + 1 }")
    end
  end

end
