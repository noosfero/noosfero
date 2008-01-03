module CategoriesHelper

  include GetText

  COLORS = [
    [ N_('Do not display at the menu'), nil ],
    [ N_('Orange'), 1 ],
    [ N_('Green'), 2 ],
    [ N_('Purple'), 3 ],
    [ N_('Red'), 4 ],
  ]

  TYPES = [
    [ _('General Category'), Category.to_s ],
    [ _('Product Category'), ProductCategory.to_s ],
    [ _('Region'), Region.to_s ],
  ]

  def select_color_for_category
    if @category.top_level?
      labelled_form_field(_('Display at the menu?'), select('category', 'display_color', CategoriesHelper::COLORS.map {|item| [gettext(item[0]), item[1]] }))
    else
      ""
    end
  end

  def display_color_for_category(category)
    color = category.display_color
    if color.nil?
      ""
    else
      "[" + gettext(CategoriesHelper::COLORS.find {|item| item[1] == color}.first) + "]"
    end
  end

  def select_category_type(field)
    value = params[field]
    labelled_form_field(_('Type of category'), select_tag('type', options_for_select(CategoriesHelper::TYPES, value)))
  end

end
