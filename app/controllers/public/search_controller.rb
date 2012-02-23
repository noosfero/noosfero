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
    if !@empty_query
      full_text_search ['public:true']
    else
      @results[@asset] = @environment.articles.public.send(@filter).paginate(paginate_options)
      facets = {}
    end
  end

  def contents
    redirect_to params.merge(:action => :articles)
  end

  def people
    if !@empty_query
      full_text_search ['public:true']
    else
      @results[@asset] = @environment.people.visible.send(@filter).paginate(paginate_options)
      @facets = {}
    end
  end

  def products
    if !@empty_query
      full_text_search ['public:true']
    else
      @results[@asset] = @environment.products.send(@filter).paginate(paginate_options)  
      @facets = {}
    end
  end

  def enterprises
    if !@empty_query
      full_text_search ['public:true']
    else
      @filter_title = _('Enterprises from network')
      @results[@asset] = @environment.enterprises.visible.paginate(paginate_options)
    end
  end

  def communities
    if !@empty_query
      full_text_search ['public:true']
    else
      @results[@asset] = @environment.communities.visible.send(@filter).paginate(paginate_options)
    end
  end

  def events
    @category_id = @category ? @category.id : nil

    year = (params[:year] ? params[:year].to_i : Date.today.year)
    month = (params[:month] ? params[:month].to_i : Date.today.month)
    day = (params[:day] ? params[:day].to_i : Date.today.day)
    date = Date.new(year, month, day)
    date_range = (date - 1.month)..(date + 1.month).at_end_of_month

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

  def assets
    params[:action] = params[:asset].is_a?(Array) ? :index : params.delete(:asset)
    redirect_to params
  end

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
    if is_cache_expired?(@tags_cache_key)
      @tags = environment.tag_counts
    end
  end

  def tag
    @tag = params[:tag]
    @tag_cache_key = "tag_#{CGI.escape(@tag.to_s)}_env_#{environment.id.to_s}_page_#{params[:npage]}"
    if is_cache_expired?(@tag_cache_key)
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
      'articles_more_popular' => _('More read contents from network'),
      'people_more_recent' => _('More recent people from network'),
      'people_more_active' => _('More active people from network'),
      'people_more_popular' => _('More popular people from network'),
      'communities_more_recent' => _('More recent communities from network'),  
      'communities_more_active' => _('More active communities from network'),  
      'communities_more_popular' => _('More popular communities from network'),
      'products_more_recent' => _('More recent products from network'),
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

  def full_text_search(filters = [])
    paginate_options = paginate_options(params[:page])
    asset_class = asset_class(@asset)

    solr_options = {}
    if !@results_only and asset_class.methods.include?('facets')
      solr_options.merge! asset_class.facets_find_options(params[:facet])
      solr_options[:all_facets] = true
      solr_options[:limit] = 0 if @facets_only
      #solr_options[:facets][:browse] << asset_class.facet_category_query.call(@category) if @category and asset_class.facet_category_query
    end
    solr_options[:order] = params[:order_by] if params[:order_by]
    solr_options[:filter_queries] ||= []
    solr_options[:filter_queries] += filters
    solr_options[:filter_queries] << "environment_id:#{environment.id}"

    ret = asset_class.find_by_contents(@query, paginate_options, solr_options)
    @results[@asset] = ret[:results]
    @facets = ret[:facets]
    @all_facets = ret[:all_facets]
  end

end
