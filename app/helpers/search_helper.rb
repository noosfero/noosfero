module SearchHelper

  MAP_SEARCH_LIMIT = 2000
  LIST_SEARCH_LIMIT = 20
  BLOCKS_SEARCH_LIMIT = 24
  MULTIPLE_SEARCH_LIMIT = 8

  SEARCHES = ActiveSupport::OrderedHash[
    :articles, _('Contents'),
    :enterprises, _('Enterprises'),
    :people, _('People'),
    :communities, _('Communities'),
    :products, _('Products and Services'),
    :events, _('Events'),
  ]

  # FIXME remove it after search_controler refactored
  include EventsHelper

  def multiple_search?
    ['index', 'category_index'].include?(params[:action]) or @searches.size > 1
  end

  def map_search?
    !multiple_search? && params[:display] == 'map'
  end

  def asset_class(asset)
    asset.to_s.singularize.camelize.constantize
  end

  def search_page_title(title, category = nil)
    title = "<h1>" + title
    title += ' - <small>' + category.name + '</small>' if category
    title + "</h1>"
  end

  def category_context(category, url)
    content_tag('div', category.full_name + _(', ') +
        link_to(_('search in all categories'),
          url.merge(:category_path => [], :action => (params[:action] == 'category_index' ? 'index' : params[:action]) )),
      :align => 'center', :class => 'search-category-context') if category
  end

  def display_map?(asset)
    [:enterprises, :products].include?(asset)
  end

  def display_items?(asset)
    puts "\n\n" + asset.inspect + "\n\n"
    ![:products, :events].include?(asset)
  end

  def display_full?(asset)
    [:enterprises, :products].include?(asset)
  end

  def display_results(asset = nil)
    if display_map?(asset) and map_search?
      partial = 'google_maps'
      klass = 'map'
    else
      partial = 'display_results'
      klass = 'list'
    end

    content_tag('div', render(:partial => partial), :class => "map-or-list-search-results #{klass}")
  end

  def city_with_state(city)
    if city and city.kind_of?(City)
      s = city.parent
      if s and s.kind_of?(State) and s.acronym
        city.name + ', ' + s.acronym
      else
        city.name
      end
    else
      nil
    end
  end

  def display_selector(asset, display, float = 'right')
    if [display_map?(asset), display_items?(asset), display_full?(asset)].select {|option| option}.count > 1
      items_link = display_items?(asset) ? (display == 'items' ? _('Items') : link_to(_('Items'), params.merge(:display => 'items'))) : nil
      map_link = display_map?(asset) ? (display == 'map' ? _('Map') : link_to(_('Map'), params.merge(:display => 'map'))) : nil
      full_link = display_full?(asset) ? (display == 'full' ? _('Full') : link_to(_('Full'), params.merge(:display => 'full'))) : nil
      content_tag('div', 
        content_tag('strong', _('Display')) + ': ' + [items_link, map_link, full_link].compact.join(' | '),
        :id => 'search-display-filter',
        :style => "float: #{float}"
      )
    end
  end

  def filter_title(asset, filter)
    {
      'articles_more_recent' => _('More recent contents from network'),
      'articles_more_popular' => _('More viewed contents from network'),
      'articles_more_comments' => _('Most commented contents from network'),
      'people_more_recent' => _('More recent people from network'),
      'people_more_active' => _('More active people from network'),
      'people_more_popular' => _('More popular people from network'),
      'communities_more_recent' => _('More recent communities from network'),
      'communities_more_active' => _('More active communities from network'),
      'communities_more_popular' => _('More popular communities from network'),
      'enterprises_more_recent' => _('More recent enterprises from network'),
      'enterprises_more_active' => _('More active enterprises from network'),
      'enterprises_more_popular' => _('More popular enterprises from network'),
      'products_more_recent' => _('Highlights'),
    }[asset.to_s + '_' + filter].to_s
  end

end
