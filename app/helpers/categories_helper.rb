module CategoriesHelper

  include GetText

  COLORS = [
    [ N_('Do not display at the menu'), nil ],
    [ N_('Blue'), 1 ],
    [ N_('Red'), 2 ],
    [ N_('Green'), 3 ],
    [ N_('Orange'), 4 ],
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

end
