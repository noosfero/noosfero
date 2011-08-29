module SearchHelper

  # FIXME remove it after search_controler refactored
  include EventsHelper

  def relevance_for(hit)
    n = (hit.ferret_score if hit.respond_to?(:ferret_score))
    n ||= 1.0
    (n * 100.0).round
  end

  def display_results(use_map = true)

    unless use_map && GoogleMaps.enabled?(environment.default_hostname)
      return render(:partial => 'display_results')
    end

    data =
      if params[:display] == 'map'
        {
          :partial => 'google_maps',
          :toggle => button(:search, _('Display in list'), params.merge(:display => 'list'), :class => "map-toggle-button" ),
          :class => 'map' ,
        }
      else
        {
          :partial => 'display_results',
          :toggle => button(:search, _('Display in map'), params.merge(:display => 'map'), :class => "map-toggle-button" ),
          :class => 'list' ,
        }
      end

    content_tag('div', data[:toggle] + (render :partial => data[:partial]), :class => "map-or-list-search-results #{data[:class]}")
  end

  def product_categories_menu(asset, product_category, object_ids = nil)
    cats = ProductCategory.menu_categories(@product_category, environment)
    cats += cats.select { |c| c.children_count > 0 }.map(&:children).flatten
    product_categories_ids = cats.map(&:id)

    counts = @noosfero_finder.product_categories_count(asset, product_categories_ids, object_ids)

    product_categories_menu = ProductCategory.menu_categories(product_category, environment).map do |cat|
      hits = counts[cat.id]
      childs = []
      if hits
        if cat.children_count > 0
          childs = cat.children.map do |child|
            child_hits = counts[child.id]
            [child, child_hits]
          end.select{|child, child_hits| child_hits }
        else
          childs = []
        end
      end
      [cat, hits, childs]
    end.select{|cat, hits| hits }

    render(:partial => 'product_categories_menu', :object => product_categories_menu)
  end

  def facets_menu(asset, _facets)
    @asset_class = asset_class(asset)
    @facets = _facets
    render(:partial => 'facets_menu')
  end

  def facets_unselect_menu(asset)
    @asset_class = asset_class(asset)
    render(:partial => 'facets_unselect_menu')
  end
  
  def facet_javascript(input_id, facet, array)
    hintText = _('Type in an option')
    text_field_tag('facet['+input_id+']', '', :id => input_id) +
      javascript_tag("jQuery.TokenList(jQuery('##{input_id}'), #{array.to_json},
        {searchDelay: 0, permanentDropdown: true, theme: 'facet', dontAdd: true, preventDuplicates: true,
        #{jquery_token_input_messages_json(hintText)}});")
  end

  def facet_link_html(facet, params, value, label, count)
    params = params.dup
    has_extra = label.kind_of?(Array)
    link_label = has_extra ? label[0] : label
    id = facet[:solr_field].to_s
    params[:facet] ||= {}
    params[:facet][id] ||= {}

    selected = facet[:label_id].nil? ? params[:facet][id] == value : params[:facet][id][facet[:label_id]].to_a.include?(value)

    if count > 0
      url = params.merge(:facet => params[:facet].merge(
        id => facet[:label_id].nil? ? value : params[:facet][id].merge( facet[:label_id] => params[:facet][id][facet[:label_id]].to_a.push(value) )
      ))
    else
      url = params.merge(:facet => {
        id => facet[:label_id].nil? ? value : { facet[:label_id] => value }
      })
    end

    content_tag 'div', link_to(link_label, url, :class => 'facet-result-link-label') +
        content_tag('span', (has_extra ? label[1] : ''), :class => 'facet-result-extra-label') +
        (count > 0 ? content_tag('span', " (#{count})", :class => 'facet-result-count') : ''),
      :class => 'facet-menu-item' + (selected ? ' facet-result-link-selected' : '')
  end

  def facet_selecteds_html_for(environment, klass, params)
    def name_with_extra(klass, facet, value)
      name = klass.facet_result_name(facet, value)
      name = name[0] + name[1] if name.kind_of?(Array) 
      name
    end

    ret = []
    params = params.dup
    params[:facet].each do |id, value|
      facet = klass.facet_by_id(id.to_sym)
      if value.kind_of?(Hash)
        label_hash = facet[:label].call(environment)
        value.each do |label_id, value|
          facet[:label_id] = label_id
          facet[:label] = label_hash[label_id]
          value.to_a.each do |value|
            ret << [facet[:label], name_with_extra(klass, facet, value),
              params.merge(:facet => params[:facet].merge(id => params[:facet][id].merge(label_id => params[:facet][id][label_id].to_a.reject{ |v| v == value })))]
          end
        end
      else
        ret << [facet[:label], name_with_extra(klass, facet, value),
          params.merge(:facet => params[:facet].reject{ |k,v| k == id })]
      end
    end

    ret.map do |label, name, url|
      content_tag('div', content_tag('span', label, :class => 'facet-selected-label') + 
        content_tag('span', name, :class => 'facet-selected-name') +
        link_to('', url, :class => 'facet-selected-remove'), :class => 'facet-selected')
    end.join
  end

  def asset_class(asset)
    asset.to_s.singularize.camelize.constantize
  end
  
  def asset_table(asset)
    asset_class(asset).table_name
  end

  def order_by(asset)
    options = {
      :products => [[_('Best match'), ''], [_('Name'), 'name_sort asc'], [_('Lower price'), 'price asc'], [_('Higher price'), 'price desc']],
      :events => [[_('Best match'), ''], [_('Name'), 'name_sort asc']],
      :articles => [[_('Best match'), ''], [_('Name'), 'name_sort asc'], [_('Most recent'), 'updated_at desc']],
      :enterprises => [[_('Best match'), ''], [_('Name'), 'name_sort asc']],
      :people => [[_('Best match'), ''], [_('Name'), 'name_sort asc']],
      :communities  => [[_('Best match'), ''], [_('Name'), 'name_sort asc']],
    }

    content_tag('div', _('Order by ') +
                select_tag(asset.to_s + '[order]', options_for_select(options[asset], params[:order_by]),
                           {:onchange => "window.location=jQuery.param.querystring(window.location.href, { 'order_by' : this.options[this.selectedIndex].value})"}),
                :class => "search-ordering")
  end

  def label_total_found(asset, total_found)
    labels = {
      :products => _("%s products offers found"),
      :articles => _("%s articles found"),
      :events => _("%s events found"),
      :people => _("%s people found"),
      :enterprises => _("%s enterprises found"),
      :communities => _("%s communities found"),
    }
    if labels[asset]
      content_tag('span', labels[asset] % total_found,
                  :class => "total-pages-found")
    else
      ''
    end
  end
end
