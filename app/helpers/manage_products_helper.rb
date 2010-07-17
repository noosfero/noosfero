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

  def options_for_select_categories(categories, selected = nil)
    categories.sort_by{|cat| cat.name.transliterate}.map do |category|
      selected_attribute = selected.nil? ? '' : (category == selected ? "selected='selected'" : '')
      "<option value='#{category.id}' #{selected_attribute}>#{category.name + (category.leaf? ? '': ' &raquo;')}</option>"
    end.join("\n")
  end

  def build_selects_for_ancestors(ancestors, last_level)
    current_category = ancestors.shift
    if current_category.nil?
      content_tag('div', '<!-- no categories -->',
        :class => 'categories_container',
        :id => "categories_container_level#{ last_level }"
      )
    else
      content_tag('div',
        select_tag('category_id',
          options_for_select_categories(current_category.siblings + [current_category], current_category),
          :size => 10,
          :onchange => remote_function_to_update_categories_selection("categories_container_level#{ current_category.level + 1 }", :with => "'category_id=' + this.value")
        ) +
        build_selects_for_ancestors(ancestors, last_level),
        :class => 'categories_container',
        :id => "categories_container_level#{ current_category.level }"
      )
    end
  end

  def selects_for_all_ancestors(current_category)
    build_selects_for_ancestors(current_category.ancestors.reverse + [current_category], current_category.level + 1)
  end

  def select_for_new_category
    content_tag('div',
      render(:partial => 'categories_for_selection'),
      :class => 'categories_container',
      :id => 'categories_container_level0'
    )
  end

  def categories_container(field_id_html, categories_selection_html, hierarchy_html = '')
    field_id_html +
    content_tag('div', hierarchy_html, :id => 'hierarchy_navigation') +
    content_tag('div', categories_selection_html, :id => 'categories_container_wrapper')
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

  def edit_product_link(product, field, label, html_options = {})
    return '' unless (user && user.has_permission?('manage_products', profile))
    options = html_options.merge(:id => 'link-edit-product-' + field)

    link_to_remote(label,
                   {:update => "product-#{field}",
                   :url => { :controller => 'manage_products', :action => "edit", :id => product.id, :field => field },
                   :method => :get},
                   options)
  end

  def edit_product_button(product, field, label, html_options = {})
    the_class = 'button with-text icon-edit'
    if html_options.has_key?(:class)
     the_class << ' ' << html_options[:class]
    end
    edit_product_link(product, field, label, html_options.merge(:class => the_class))
  end

  def edit_product_ui_button(product, field, label, html_options = {})
    return '' unless (user && user.has_permission?('manage_products', profile))
    options = html_options.merge(:id => 'edit-product-button-ui-' + field)

    ui_button_to_remote(label,
                   {:update => "product-#{field}",
                   :url => { :controller => 'manage_products', :action => "edit", :id => product.id, :field => field },
                   :complete => "$('edit-product-button-ui-#{field}').hide()",
                   :method => :get},
                   options)
  end

  def cancel_edit_product_link(product, field, html_options = {})
    return '' unless (user && user.has_permission?('manage_products', profile))
    button_to_function(:cancel, _('Cancel'), nil, html_options) do |page|
      page.replace_html "product-#{field}", :partial => "display_#{field}", :locals => {:product => product}
    end
  end

  def edit_product_category_link(product, html_options = {})
    return '' unless (user && user.has_permission?('manage_products', profile))
    options = html_options.merge(:id => 'link-edit-product-category')
    link_to(_('Change category'), { :action => 'edit_category', :id => product.id}, options)
  end

  def float_to_currency(value)
    number_to_currency(value, :unit => environment.currency_unit, :separator => environment.currency_separator, :delimiter => environment.currency_delimiter, :format => "%u %n")
  end

  def display_value(product)
    price = product.price
    unless price.blank? || price.zero?
      unit = product.unit
      return '' if unit.blank?
      discount = product.discount
      if discount.blank? || discount.zero?
        display_price(_('Price: '), price, unit)
      else
        display_price_with_discount(price, unit, product.price_with_discount)
      end
    else
      ''
    end
  end

  def display_price(label, price, unit)
    content_tag('span', label, :class => 'field-name') +
    content_tag('span', float_to_currency(price), :class => 'field-value') +
    ' (%s)' % unit
  end

  def display_price_with_discount(price, unit, price_with_discount)
    original_value = content_tag('span', float_to_currency(price), :class => 'field-value')
    discount_value = display_price(_('On sale: '), price_with_discount, unit)
    content_tag('span', _('List price: '), :class => 'field-name') + original_value + "<p/>" + discount_value
  end

  def display_qualifiers(product)
    data = ''
    product.product_qualifiers.each do |pq|
      certified_by = pq.certifier ? _(' certified by %s') % link_to(pq.certifier.name, pq.certifier.link) : ''
      data << content_tag('li', '✔ ' + pq.qualifier.name + certified_by, :class => 'product-qualifiers-item')
    end
    content_tag('ul', data, :id => 'product-qualifiers')
  end

  def checkboxes_qualifiers(product, qualifier)
    check_box_tag("product[qualifiers_list][#{qualifier.id}][qualifier_id]", qualifier.id, product.qualifiers.include?(qualifier)) + qualifier.name
  end

  def select_certifiers(product, qualifier, certifiers)
    relation = product.product_qualifiers.find(:first, :conditions => {:qualifier_id => qualifier.id})
    selected = relation.nil? ? 0 : relation.certifier_id
    select_tag("product[qualifiers_list][#{qualifier.id}][certifier_id]", options_for_select([[_('Select...') , 0 ]] + certifiers.map {|c|[c.name, c.id]}, selected))
  end
end
