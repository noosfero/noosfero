module CategoriesHelper

  TYPES = [
    [ _('General Category'), Category.to_s ],
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

  def category_humane_path(category)
    category.full_name(' &rarr; ').html_safe
  end

  def category_remove_button(category)
    js_remove = "jQuery('#selected-category-#{category.id}').remove();"
    button_to_function_without_text(:remove, _('Remove'), js_remove)
  end

  def category_add_button(category)
  end

  #TODO: remove this function and, in views, use existing basic buttons
  def update_categories_link(type, body, category_id=nil, html_options={})
    html_class = 'select-subcategory-link'
    html_class = " icon-#{type}  btn btn-primary btn-xs" if type.present?
    link_to body,
      { :action => "update_categories", :category_id => category_id, :id => @object },
      {:id => category_id ? "select-category-#{category_id}-link" : nil, :remote => true, :class => html_class}.merge(html_options)
  end

  def update_categories
    @object = profile
    render_categories 'profile_data'
  end

  def render_categories object_name
    @toplevel_categories = environment.top_level_categories
    if params[:category_id]
      @current_category = Category.find(params[:category_id])
      @categories = @current_category.children
    else
      @categories = @toplevel_categories
    end
    render :template => 'shared/update_categories', :locals => { :category => @current_category, :object_name => object_name }
  end

end
