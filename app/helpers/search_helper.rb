module SearchHelper

  MAP_SEARCH_LIMIT = 2000
  LIST_SEARCH_LIMIT = 20
  BLOCKS_SEARCH_LIMIT = 24
  MULTIPLE_SEARCH_LIMIT = 8

  Searches = ActiveSupport::OrderedHash[
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
    ['index', 'category_index'].include?(params[:action]) or @results.size > 1
  end

  def map_search?
    !multiple_search? and params[:display] == 'map'
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

  def map_capable?(asset)
    [:enterprises, :products].include?(asset)
  end

  def display_results(asset = nil)
    if map_capable?(asset) and map_search?
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

  def display_filter(asset, display, float = 'right')
    if map_capable?(asset)
      list_link = display == 'list' ? _('List') : link_to(_('List'), params.merge(:display => 'list'))
      map_link = display == 'map' ? _('Map') : link_to(_('Map'), params.merge(:display => 'map'))
      content_tag('div', 
        content_tag('strong', _('Display')) + ': ' +
        list_link +
        ' | ' +
        map_link,
        :id => 'search-display-filter',
        :style => "float: #{float}"
      )
    end
  end

end
