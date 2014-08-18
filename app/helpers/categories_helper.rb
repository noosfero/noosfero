module CategoriesHelper

  TYPES = [
    [ _('General Category'), Category.to_s ],
    [ _('Product Category'), ProductCategory.to_s ],
    [ _('Region'), Region.to_s ],
  ]

  def select_category_type(field)
    value = params[field]
    labelled_form_field(_('Type of category'), select_tag('type', options_for_select(TYPES, value)))
  end

  def category_color_style(category)
    return '' if category.nil? or category.display_color.blank?
    'background-color: #'+category.display_color+';'
  end

  #FIXME make this test
  def selected_category_link(cat)
    js_remove = "jQuery('#selected-category-#{cat.id}').remove();"
    content_tag('div', button_to_function_without_text(:remove, _('Remove'), js_remove) +
      link_to_function(cat.full_name(' &rarr; '), js_remove, :id => "remove-selected-category-#{cat.id}-button", :class => 'select-subcategory-link'),
      :class => 'selected-category'
    )
  end

  def update_categories_link(body, category_id=nil, html_options={})
    link_to body,
      { :action => "update_categories", :category_id => category_id, :id => @object },
      {:id => category_id ? "select-category-#{category_id}-link" : nil, :remote => true, :class => 'select-subcategory-link'}.merge(html_options)
  end

end
