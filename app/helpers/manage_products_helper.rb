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
      count_chars = 0
      unless options[:hide_current_category]
        hierarchy << current_category.name
        count_chars += current_category.name.length
      end
      ancestors = current_category.ancestors
      toplevel = ancestors.pop
      if toplevel
        count_chars += toplevel.name.length
      end
      ancestors.each do |category|
        if count_chars > 55
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
      "<option value='#{category.id}' title='#{category.name}' #{selected_attribute}>#{truncate(category.name, 33) + (category.leaf? ? '': ' &raquo;')}</option>"
    end.join("\n")
  end

  def build_selects_for_ancestors(ancestors, current_category)
    current_ancestor = ancestors.shift
    if current_ancestor.nil?
      select_for_new_category(current_category.children, current_category.level + 1)
    else
      content_tag('div',
        select_tag('category_id',
          options_for_select_categories(current_ancestor.siblings + [current_ancestor], current_ancestor),
          :size => 10,
          :onchange => remote_function_to_update_categories_selection("categories_container_level#{ current_ancestor.level + 1 }", :with => "'category_id=' + this.value")
        ) +
        build_selects_for_ancestors(ancestors, current_category),
        :class => 'categories_container',
        :id => "categories_container_level#{ current_ancestor.level }"
      )
    end
  end

  def selects_for_all_ancestors(current_category)
    build_selects_for_ancestors(current_category.ancestors.reverse + [current_category], current_category)
  end

  def select_for_new_category(categories, level)
    content_tag('div',
      render(:partial => 'categories_for_selection', :locals => { :categories => categories, :level => level }),
      :class => 'categories_container',
      :id => "categories_container_level#{ level }"
    )
  end

  def categories_container(categories_selection_html, hierarchy_html = '')
    hidden_field_tag('selected_category_id') +
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

  def edit_link(label, url, html_options = {})
    return '' unless (user && user.has_permission?('manage_products', profile))
    link_to(label, url, html_options)
  end

  def edit_product_link_to_remote(product, field, label, html_options = {})
    return '' unless (user && user.has_permission?('manage_products', profile))
    options = html_options.merge(:id => 'link-edit-product-' + field)
    options[:class] = options[:class] ? options[:class] + ' link-to-remote' : 'link-to-remote'

    link_to_remote(label,
                   {:update => "product-#{field}",
                   :url => { :controller => 'manage_products', :action => "edit", :id => product.id, :field => field },
                   :method => :get,
                   :loading => "loading_for_button('#link-edit-product-#{field}')"},
                   options)
  end

  def edit_button(type, label, url, html_options = {})
    return '' unless (user && user.has_permission?('manage_products', profile))
    button(type, label, url, html_options)
  end

  def edit_product_button_to_remote(product, field, label, html_options = {})
    the_class = 'button with-text icon-edit'
    if html_options.has_key?(:class)
     the_class << ' ' << html_options[:class]
    end
    edit_product_link_to_remote(product, field, label, html_options.merge(:class => the_class))
  end

  def edit_ui_button(label, url, html_options = {})
    return '' unless (user && user.has_permission?('manage_products', profile))
    ui_button(label, url, html_options)
  end

  def edit_product_ui_button_to_remote(product, field, label, html_options = {})
    return '' unless (user && user.has_permission?('manage_products', profile))
    id = 'edit-product-remote-button-ui-' + field
    options = html_options.merge(:id => id)

    ui_button_to_remote(label,
                   {:update => "product-#{field}",
                   :url => { :controller => 'manage_products', :action => "edit", :id => product.id, :field => field },
                   :complete => "$('edit-product-button-ui-#{field}').hide()",
                   :method => :get,
                   :loading => "loading_for_button('##{id}')"},
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

  def display_value(product)
    price = product.price
    return '' if price.blank? || price.zero?
    discount = product.discount
    if discount.blank? || discount.zero?
      result = display_price(_('Price: '), price)
    else
      result = display_price_with_discount(price, product.price_with_discount)
    end
    content_tag('span', content_tag('span', result, :class => 'product-price'), :class => "#{product.available? ? '' : 'un'}available-product")
  end

  def display_availability(product)
    if !product.available?
      ui_highlight(_('Product not available!'))
    end
  end

  def display_price(label, price)
    content_tag('span', label, :class => 'field-name') +
    content_tag('span', float_to_currency(price), :class => 'field-value')
  end

  def display_price_with_discount(price, price_with_discount)
    original_value = content_tag('span', display_price(_('List price: '), price), :class => 'list-price')
    discount_value = content_tag('span', display_price(_('On sale: '), price_with_discount), :class => 'on-sale-price')
    original_value + tag('br') + discount_value
  end

  def display_qualifiers(product)
    data = ''
    product.product_qualifiers.each do |pq|
      certified_by = ''
      certifier = pq.certifier
      if certifier
        certifier_name = certifier.link.blank? ? certifier.name : link_to(certifier.name, certifier.link)
        certified_by = _('certified by %s') % certifier_name
      else
        certified_by = _('(Self declared)')
      end
      data << content_tag('li', "✔ #{pq.qualifier.name} #{certified_by}", :class => 'product-qualifiers-item')
    end
    content_tag('ul', data, :id => 'product-qualifiers')
  end

  def qualifiers_for_select
    [[_('Select...'), nil]] + environment.qualifiers.map{ |c| [c.name, c.id] }
  end
  def certifiers_for_select(qualifier)
    [[_('Self declared'), nil]] + qualifier.certifiers.map{ |c| [c.name, c.id] }
  end
  def select_qualifiers(product, selected = nil)
    select_tag('selected_qualifier', options_for_select(qualifiers_for_select, selected),
      :onchange => remote_function(
        :url => {:action => 'certifiers_for_selection'},
        :with => "'id=' + value + '&certifier_area=' + jQuery(this).parent().next().attr('id')",
        :before => "small_loading(jQuery(this).parent().next().attr('id'), '&nbsp;')"
      ),
      :id => nil
    )
  end
  def select_certifiers(qualifier, product = nil)
    if qualifier
      selected = product ? product.product_qualifiers.find_by_qualifier_id(qualifier.id).certifier_id : nil
      select_tag("product[qualifiers_list][#{qualifier.id}]", options_for_select(certifiers_for_select(qualifier), selected))
    else
      select_tag("product[qualifiers_list][nil]")
    end
  end

  def select_unit(object)
    collection_select(object.class.name.downcase, :unit_id, environment.units, :id, :singular, {:include_blank => _('Select the unit')})
  end

  def input_icon(input)
    if input.is_from_solidarity_economy?
      hint = _('Product from solidarity economy')
      image_tag("/images/solidarity-economy.png", :class => 'solidatiry-economy-icon', :alt => hint, :title => hint)
    end
  end

  def display_price_by(unit)
    selected_unit = content_tag('span', unit, :class => 'selected-unit')
    content_tag('span', _('by') + ' ' + selected_unit, :class => 'price-by-unit')
  end

  def label_amount_used(input)
    product_unit = input.product.unit
    if product_unit.blank?
       _('Amount used in this product or service')
    else
       _('Amount used by %s of this product or service') % product_unit.singular.downcase
    end
  end

  def display_unit(input)
    input_amount_used = content_tag('span', input.formatted_amount, :class => 'input-amount-used')
    return input_amount_used if input.unit.blank?
    n_('1 %{singular_unit}', '%{num} %{plural_unit}', input.amount_used.to_f) % { :num => input_amount_used, :singular_unit => content_tag('span', input.unit.singular, :class => 'input-unit'), :plural_unit => content_tag('span', input.unit.plural, :class => 'input-unit') }
  end
end
