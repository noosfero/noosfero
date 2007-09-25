module CategoriesHelper
  def select_color_for_category
    if @category.top_level?
      options = [
        [ _('Do not display at the menu'), nil ],
        [ _('Blue'), 1 ],
        [ _('Red'), 2 ],
        [ _('Green'), 3 ],
        [ _('Orange'), 4 ],
      ]
      labelled_form_field(_('Display at the menu?'), select('category', 'display_color', options))
    else
      ""
    end
  end

end
