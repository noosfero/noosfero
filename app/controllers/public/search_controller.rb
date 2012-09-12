class SearchController < PublicController

  helper TagsHelper
  include SearchHelper
  include ActionView::Helpers::NumberHelper

  before_filter :redirect_asset_param, :except => [:facets_browse, :assets]
  before_filter :load_category
  before_filter :load_search_assets
  before_filter :load_query

  # Backwards compatibility with old URLs
  def redirect_asset_param
    return unless params.has_key?(:asset)
    redirect_to params.merge(:action => params.delete(:asset))
  end

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
    end
  end

  def contents
    redirect_to params.merge(:action => :articles)
  end

  def people
    if !@empty_query
      full_text_search ['public:true']
    else
      @results[@asset] = visible_profiles(Person).send(@filter).paginate(paginate_options)
    end
  end

  def products
    public_filters = ['public:true', 'enabled:true']
    if !@empty_query
      full_text_search public_filters
    else
      @one_page = true
      @geosearch = logged_in? && current_user.person.lat && current_user.person.lng

      extra_limit = LIST_SEARCH_LIMIT*5
      sql_options = {:limit => LIST_SEARCH_LIMIT, :order => 'random()'}
      if @geosearch
        full_text_search public_filters, :sql_options => sql_options, :extra_limit => extra_limit,
          :alternate_query => "{!boost b=recip(geodist(),#{"%e" % (1.to_f/DistBoost)},1,1)}",
          :radius => DistFilt, :latitude => current_user.person.lat, :longitude => current_user.person.lng
      else
        full_text_search public_filters, :sql_options => sql_options, :extra_limit => extra_limit,
          :boost_functions => ['recip(ms(NOW/HOUR,updated_at),1.3e-10,1,1)']
      end
    end
  end

  def enterprises
    if !@empty_query
      full_text_search ['public:true']
    else
      @filter_title = _('Enterprises from network')
      @results[@asset] = visible_profiles(Enterprise, [{:products => :product_category}]).paginate(paginate_options)
    end
  end

  def communities
    if !@empty_query
      full_text_search ['public:true']
    else
      @results[@asset] = visible_profiles(Community).send(@filter).paginate(paginate_options)
    end
  end

  def events
    year = (params[:year] ? params[:year].to_i : Date.today.year)
    month = (params[:month] ? params[:month].to_i : Date.today.month)
    day = (params[:day] ? params[:day].to_i : Date.today.day)
    date = build_date(params[:year], params[:month], params[:day])
    date_range = (date - 1.month)..(date + 1.month).at_end_of_month

    @selected_day = nil
    @events_of_the_day = []
    if params[:day] || !params[:year] && !params[:month]
      @selected_day = date
      @events_of_the_day = @category ?
        environment.events.by_day(@selected_day).in_category(Category.find(@category_id)) :
        environment.events.by_day(@selected_day)
    end

    if !@empty_query
      full_text_search
    else
      @results[@asset] = date_range ? environment.events.by_range(date_range) : environment.events
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

    @enabled_searches.select { |key,description| @searching[key] }.each do |key, description|
      load_query
      @asset = key
      send(key)
      @order << key
      @names[key] = getterm(description)
    end
    @asset = nil
    @facets = {}

    render :action => @results.keys.first if @results.keys.size == 1
  end

  # keep old URLs workings
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
      raise "No total_entries for: #{asset}" unless @results[asset].respond_to?(:total_entries)
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
      @results[@asset] = environment.articles.find_tagged_with(@tag).paginate(paginate_options)
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
    if params[:category_path].blank?
      render_not_found if params[:action] == 'category_index'
    else
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
    more_comments
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
      'articles_more_popular' => _('More viewed contents from network'),
      'articles_more_comments' => _('Most commented contents from network'),
      'people_more_recent' => _('More recent people from network'),
      'people_more_active' => _('More active people from network'),
      'people_more_popular' => _('More popular people from network'),
      'communities_more_recent' => _('More recent communities from network'),
      'communities_more_active' => _('More active communities from network'),
      'communities_more_popular' => _('More popular communities from network'),
      'products_more_recent' => _('Highlights'),
    }[asset.to_s + '_' + filter]
  end

  def load_search_assets
    if Searches.keys.include?(params[:action].to_sym) and environment.enabled?("disable_asset_#{params[:action]}")
      render_not_found
      return
    end

    @enabled_searches = Searches.select {|key, name| environment.disabled?("disable_asset_#{params[:action]}") }
    @searching = {}
    @titles = {}
    @enabled_searches.each do |key, name|
      @titles[key] = _(name)
      @searching[key] = params[:action] == 'index' || params[:action] == key.to_s
    end
    @names = @titles if @names.nil?
  end

  def limit
    if map_search?
      MAP_SEARCH_LIMIT
    elsif !multiple_search?
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
    page = 1 if multiple_search? or params[:display] == 'map'
    { :per_page => limit, :page => page }
  end

  def full_text_search(filters = [], options = {})
    paginate_options = paginate_options(params[:page])
    asset_class = asset_class(@asset)
    solr_options = options
    pg_options = paginate_options(params[:page])

    if !multiple_search?
      if !@results_only and asset_class.respond_to? :facets
        solr_options.merge! asset_class.facets_find_options(params[:facet])
        solr_options[:all_facets] = true
      end
      solr_options[:filter_queries] ||= []
      solr_options[:filter_queries] += filters
      solr_options[:filter_queries] << "environment_id:#{environment.id}"
      solr_options[:filter_queries] << asset_class.facet_category_query.call(@category) if @category

      solr_options[:boost_functions] ||= []
      params[:order_by] = nil if params[:order_by] == 'none'
      if params[:order_by]
        order = SortOptions[@asset][params[:order_by].to_sym]
        raise "Unknown order by" if order.nil?
        order[:solr_opts].each do |opt, value|
          solr_options[opt] = value.is_a?(Proc) ? instance_eval(&value) : value
        end
      end
    end

    ret = asset_class.find_by_contents(@query, paginate_options, solr_options)
    @results[@asset] = ret[:results]
    @facets = ret[:facets]
    @all_facets = ret[:all_facets]
  end

  private

  def visible_profiles(klass, *extra_relations)
    relations = [:image, :domains, :environment, :preferred_domain]
    relations += extra_relations
    @environment.send(klass.name.underscore.pluralize).visible.includes(relations)
  end

end
