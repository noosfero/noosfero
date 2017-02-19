module CategoriesHelper

  def category_types(plural = false)
    plural = plural ? 2 : 1
    [
      [ n_('General category', 'General categories', plural), Category.to_s ],
      [ n_('Region', 'Regions', plural), Region.to_s ],
    ] + @plugins.dispatch_without_flatten(:extra_category_types, plural).flatten(1)
  end

  def root_categories_for(category_type)
    categories = environment.try(category_type.underscore.pluralize) ||
                 environment.categories.where("type='#{category_type}'")
    categories.where(parent_id: nil)
  end

  def select_category_type(field)
    value = params[field]
    labelled_form_field(_('Type of category'), select_tag('type', options_for_select(category_types, value)))
  end

  def category_color_style(category)
    return '' if category.nil? or category.display_color.blank?
    'background-color: #'+category.display_color+';'
  end

  def category_humane_path(category)
    category.full_name(' &rarr; ').html_safe
  end

  def update_categories
    @object = profile
    render_categories 'profile_data'
  end

  def render_categories object_name
    kind = params[:kind] || :categories
    @toplevel_categories = environment.send("top_level_#{kind}")

    if params[:category_id]
      @current_category = Category.find(params[:category_id])
      @categories = @current_category.children
    else
      @categories = @toplevel_categories
    end

    render :template => 'shared/update_categories',
           :locals => {
             :category => @current_category,
             :object_name => object_name,
             :kind => kind
           }
  end

end
