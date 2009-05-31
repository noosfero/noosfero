module SearchHelper

  STOP_WORDS = {
    'pt_BR' => Ferret::Analysis::FULL_PORTUGUESE_STOP_WORDS,
    'en'    => Ferret::Analysis::FULL_ENGLISH_STOP_WORDS,
  }
  
  def relevance_for(hit)
    n = (hit.ferret_score if hit.respond_to?(:ferret_score))
    n ||= 1.0
    (n * 100.0).round
  end

  def remove_stop_words(query)
    (query.downcase.scan(/"[^"]*"?|'[^']*'?|[^'"\s]+/) - (STOP_WORDS[locale] || [])).join(' ')
  end

  def display_results(use_map = true)

    unless use_map && GoogleMaps.enabled?
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

  def display_item_map_info(item)
    if item.kind_of?(Profile)
      display_profile_info(item)
    elsif item.kind_of?(Product)
      display_product_info(item)
    end
  end
  
  def display_profile_info(profile)
    data = ''
    unless profile.contact_email.nil?
      data << content_tag('strong', _('E-Mail: ')) + profile.contact_email + '<br/>'
    end
    unless profile.contact_phone.nil?
      data << content_tag('strong', _('Phone(s): ')) + profile.contact_phone + '<br/>'
    end
    unless profile.region.nil?
      data << content_tag('strong', _('Location: ')) + profile.region.name + '<br/>'
    end
    unless profile.address.nil?
      data << content_tag('strong', _('Address: ')) + profile.address + '<br/>'
    end
    unless profile.products.empty?
      data << content_tag('strong', _('Products/Services: ')) + profile.products.map{|i| link_to(i.name, :controller => 'catalog', :profile => profile.identifier, :action => 'show', :id => i)}.join(', ') + '<br/>'
    end
    if profile.respond_to?(:distance) and !profile.distance.nil?
      data << content_tag('strong', _('Distance: ')) + "%.2f%" % profile.distance + '<br/>'
    end
    content_tag('table',
      content_tag('tr',
        content_tag('td', content_tag('div', profile_image(profile, :thumb), :class => 'profile-info-picture')) +
        content_tag('td', content_tag('strong', link_to(profile.name, url_for(profile.url))) + '<br/>' + data
        )
      ),
      :class => 'profile-info'
    )
  end

  def display_product_info(product)
    data = ''
    unless product.price.nil?
      data << content_tag('strong', _('Price: ')) + product.price + '<br/>'
    end
    unless product.enterprise.nil?
      data << content_tag('strong', _('Provider: ')) + link_to_profile(product.enterprise.name, product.enterprise.identifier)
    end
    unless product.product_category.nil?
      data << content_tag('strong', _('Category: ')) + link_to(product.product_category.name, :controller => 'search', :action => 'assets', :asset => 'products', :product_category => product.product_category.id)
    end
    content_tag('table',
      content_tag('tr',
        content_tag('td', content_tag('div', image_tag(product.image ? product.image.public_filename(:thumb) : '/images/icons-app/product-default-pic-portrait.png'), :class => 'profile-info-picture')) +
        content_tag('td', content_tag('strong', link_to(product.name, :controller => 'catalog', :profile => product.enterprise.identifier, :action => 'show', :id => product)) + '<br/>' + data)
        ), :class => 'profile-info')
  end

  def pagination_links(collection, options={})
    options = {:prev_label => '&laquo; ' + _('Previous'), :next_label => _('Next') + ' &raquo;'}.merge(options)
    will_paginate(collection, options)
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

end
