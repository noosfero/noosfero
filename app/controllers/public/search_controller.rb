class SearchController < PublicController

  MAP_SEARCH_LIMIT = 2000
  LIST_SEARCH_LIMIT = 20
  BLOCKS_SEARCH_LIMIT = 18
  MULTIPLE_SEARCH_LIMIT = 8

  helper TagsHelper
  include SearchHelper
  include ActionView::Helpers::NumberHelper

  before_filter :load_category
  before_filter :load_search_assets
  before_filter :load_query

  no_design_blocks

  def facets_browse
    @asset = params[:asset]
    @asset_class = asset_class(@asset)

    @facets_only = true
    send(@asset)

    @facet = @asset_class.map_facets_for(environment).find { |facet| facet[:id] == params[:facet_id] }
    raise 'Facet not found' if @facet.nil?

    render :layout => false
  end

  def articles
    @filter = params[:filter] ? filter : nil
    @filter_title = params[:filter] ? filter_description(@asset, @filter) : nil
    if !@empty_query
      full_text_search
    elsif params[:filter]
      @results[@asset] = @environment.articles.more_recent.paginate(paginate_options)
    end
  end

  def contents
    redirect_to params.merge(:action => :articles)
  end

  def people
    if !@empty_query
      full_text_search
    else
      @results[@asset] = @environment.people.visible.send(@filter).paginate(paginate_options)
      @facets = {}
    end
  end

  def products
    if !@empty_query
      full_text_search
    end
  end

  def enterprises
    if !@empty_query
      full_text_search
    else
      @filter_title = _('Enterprises from network')
      @results[@asset] = asset_class(@asset).paginate(paginate_options)
    end
  end

  def communities
    if !@empty_query
      full_text_search
    else
      @results[@asset] = @environment.communities.visible.send(@filter).paginate(paginate_options)
    end
  end

  def events
    @category_id = @category ? @category.id : nil

    if params[:year] || params[:month]
      date = Date.new(year.to_i, month.to_i, 1)
      date_range = (date - 1.month)..(date + 1.month).at_end_of_month
    end

    if @query.blank?
      # Ignore pagination for asset events
      if date_range
        @results[@asset] = Event.send('find', :all, 
          :conditions => [
            'start_date BETWEEN :start_day AND :end_day OR end_date BETWEEN :start_day AND :end_day',
            {:start_day => date_range.first, :end_day => date_range.last}
        ])
      else
        @results[@asset] = Event.send('find', :all)
      end
    else
      full_text_search
    end

    @selected_day = nil
    @events_of_the_day = []
    date = build_date(params[:year], params[:month], params[:day])

    if params[:day] || !params[:year] && !params[:month]
      @selected_day = date
      if @category_id and Category.exists?(@category_id)
        @events_of_the_day = environment.events.by_day(@selected_day).in_category(Category.find(@category_id))
      else
        @events_of_the_day = environment.events.by_day(@selected_day)
      end
    end

    events = @results[@asset]
    @calendar = populate_calendar(date, events)
    @previous_calendar = populate_calendar(date - 1.month, events)
    @next_calendar = populate_calendar(date + 1.month, events)
  end

  def index
    @results = {}
    @order = []
    @names = {}
    @results_only = true

    @enabled_searchs.select { |key,description| @searching[key] }.each do |key, description|
      load_query
      @asset = key
      send(key)
      @order << key
      @names[key] = getterm(description)
    end
    @asset = nil
    @facets = {}

    if @results.keys.size == 1
      specific_action = @results.keys.first
      if respond_to?(specific_action)
        @asset_name = getterm(@names[@results.keys.first])
        send(specific_action)
        render :action => specific_action
        return
      end
    end
  end

  alias :assets :index

  # view the summary of one category
  def category_index
    @results = {}
    @order = []
    @names = {}
    limit = MULTIPLE_SEARCH_LIMIT
    [
      [ :people, _('People'), :recent_people ],
      [ :enterprises, _('Enterprises'), :recent_enterprises ],
      [ :products, _('Products'), :recent_products ],
      [ :events, _('Upcoming events'), :upcoming_events ],
      [ :communities, _('Communities'), :recent_communities ],
      [ :articles, _('Contents'), :recent_articles ]
    ].each do |asset, name, filter|
      @order << asset
      @results[asset] = @category.send(filter, limit)
      @names[asset] = name
    end
  end

  def tags
    @tags_cache_key = "tags_env_#{environment.id.to_s}"
    if is_cache_expired?(@tags_cache_key, true)
      @tags = environment.tag_counts
    end
  end

  def tag
    @tag = params[:tag]
    @tag_cache_key = "tag_#{CGI.escape(@tag.to_s)}_env_#{environment.id.to_s}_page_#{params[:npage]}"
    if is_cache_expired?(@tag_cache_key, true)
      @tagged = environment.articles.find_tagged_with(@tag).paginate(:per_page => 10, :page => params[:npage])
    end
  end

  def events_by_day
    @selected_day = build_date(params[:year], params[:month], params[:day])
    @events_of_the_day = environment.events.by_day(@selected_day)
    render :partial => 'events/events_by_day'
  end

  #######################################################
  protected

  def load_query
    @asset = params[:action].to_sym
    @order ||= [@asset]
    @results ||= {}
    @filter = filter 
    @filter_title = filter_description(@asset, @filter)

    @query = params[:query] || ''
    @empty_query = @category.nil? && @query.blank?
  end

  def load_category
    unless params[:category_path].blank?
      path = params[:category_path].join('/')
      @category = environment.categories.find_by_path(path)
      if @category.nil?
        render_not_found(path)
      else 
        @category_id = @category.id
      end
    end
  end

  FILTERS = %w(
    more_recent
    more_active
    more_popular
  )
  def filter
    if FILTERS.include?(params[:filter])
      params[:filter]
    else
      'more_recent'
    end
  end

  def filter_description(asset, filter)
    {
      'articles_more_recent' => _('More recent contents from network'),
      'articles_more_popular' => _('More popular contents from network'),
      'people_more_recent' => _('More recent people from network'),
      'people_more_active' => _('More active people from network'),
      'people_more_popular' => _('More popular people from network'),
      'communities_more_recent' => _('More recent communities from network'),  
      'communities_more_active' => _('More active communities from network'),  
      'communities_more_popular' => _('More popular communities from network'),
    }[asset.to_s + '_' + filter]
  end

  def load_search_assets
    @enabled_searchs = [
      [ :articles, _('Contents') ],
      [ :enterprises, _('Enterprises') ],
      [ :people, _('People') ],
      [ :communities, _('Communities') ],
      [ :products, _('Products and Services') ],
      [ :events, _('Events') ]
    ].select {|key, name| !environment.enabled?('disable_asset_' + key.to_s) }

    @searching = {}
    @titles = {}
    @enabled_searchs.each do |key, name|
      @titles[key] = name
      @searching[key] = params[:action] == 'index' || params[:action] == key.to_s
    end
  end

  def limit
    searching = @searching.values.select{ |v| v }
    if params[:display] == 'map'
      MAP_SEARCH_LIMIT
    elsif searching.size <= 1
      if [:people, :communities].include? @asset
        BLOCKS_SEARCH_LIMIT
      elsif @asset == :enterprises and @empty_query
        BLOCKS_SEARCH_LIMIT
      else
        LIST_SEARCH_LIMIT
      end
    else
      MULTIPLE_SEARCH_LIMIT
    end
  end

  def paginate_options(page = params[:page])
    { :per_page => limit, :page => page }
  end

  def full_text_search(paginate_options = nil)
    paginate_options ||= paginate_options(params[:page])
    solr_options = solr_options(@asset, params[:facet], params[:order_by])

    ret = asset_class(@asset).find_by_contents(@query, paginate_options, solr_options)
    @results[@asset] = ret[:results]
    @facets = ret[:facets]
    @all_facets = ret[:all_facets]
  end

  def solr_options(asset, facets_selected, solr_order = nil)
    result = {}

    asset_class = asset_class(asset)
    if !@results_only and asset_class.methods.include?('facets')
      result.merge! asset_class.facets_find_options(facets_selected)
      result[:all_facets] = true
      result[:limit] = 0 if @facets_only
      result[:facets][:browse] << asset_class.facet_category_query.call(@category) if @category
      puts result[:facets][:browse]
    end

    result[:order] = solr_order if solr_order

    result
  end

end
