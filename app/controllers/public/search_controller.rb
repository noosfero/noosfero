class SearchController < PublicController

  helper TagsHelper
  include SearchHelper
  include ActionView::Helpers::NumberHelper

  before_filter :redirect_asset_param, :except => :assets
  before_filter :load_category
  before_filter :load_search_assets
  before_filter :load_query
  before_filter :load_filter

  # Backwards compatibility with old URLs
  def redirect_asset_param
    return unless params.has_key?(:asset)
    redirect_to params.merge(:action => params.delete(:asset))
  end

  no_design_blocks

  def index
    @searches = {}
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

    if @searches.keys.size == 1
      @asset = @searches.keys.first
      render :action => @asset
    end
  end

  # view the summary of one category
  def category_index
    @searches = {}
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
      @searches[asset]= {:results => @category.send(filter, limit)}
      raise "No total_entries for: #{asset}" unless @searches[asset][:results].respond_to?(:total_entries)
      @names[asset] = name
    end
  end

  def articles
    @scope = @environment.articles.public
    full_text_search
  end

  def contents
    redirect_to params.merge(:action => :articles)
  end

  def people
    @scope = visible_profiles(Person)
    full_text_search
  end

  def products
    @scope = @environment.products
    full_text_search
  end

  def enterprises
    @scope = visible_profiles(Enterprise, [{:products => :product_category}])
    full_text_search
  end

  def communities
    @scope = visible_profiles(Community)
    full_text_search
  end

  def events
    year = (params[:year] ? params[:year].to_i : Date.today.year)
    month = (params[:month] ? params[:month].to_i : Date.today.month)
    day = (params[:day] ? params[:day].to_i : Date.today.day)
    @date = build_date(year, month, day)
    date_range = (@date - 1.month).at_beginning_of_month..(@date + 1.month).at_end_of_month

    @events = []
    if params[:day] || !params[:year] && !params[:month]
      @events = @category ?
        environment.events.by_day(@date).in_category(Category.find(@category_id)) :
        environment.events.by_day(@date)
    end

    if params[:year] || params[:month]
      @events = @category ?
        environment.events.by_month(@date).in_category(Category.find(@category_id)) :
        environment.events.by_month(@date)
    end

    @scope = date_range && params[:action] == 'events' ? environment.events.by_range(date_range) : environment.events
    full_text_search

    events = @searches[@asset][:results]
    @calendar = populate_calendar(@date, events)
    @previous_calendar = populate_calendar(@date - 1.month, events)
    @next_calendar = populate_calendar(@date + 1.month, events)
  end

  # keep old URLs workings
  def assets
    params[:action] = params[:asset].is_a?(Array) ? :index : params.delete(:asset)
    redirect_to params
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
      @searches[@asset] = {:results => environment.articles.find_tagged_with(@tag).paginate(paginate_options)}
    end
  end

  def events_by_day
    @date = build_date(params[:year], params[:month], params[:day])
    @events = environment.events.by_day(@date)
    render :partial => 'events/events'
  end

  #######################################################
  protected

  def load_query
    @asset = (params[:asset] || params[:action]).to_sym
    @order ||= [@asset]
    @searches ||= {}

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

  def load_search_assets
    if SEARCHES.keys.include?(params[:action].to_sym) && environment.enabled?("disable_asset_#{params[:action]}")
      render_not_found
      return
    end

    @enabled_searches = SEARCHES.select {|key, name| environment.disabled?("disable_asset_#{key}") }
    @searching = {}
    @titles = {}
    @enabled_searches.each do |key, name|
      @titles[key] = _(name)
      @searching[key] = params[:action] == 'index' || params[:action] == key.to_s
    end
    @names = @titles if @names.nil?
  end

  def load_filter
    @filter = 'more_recent'
    if SEARCHES.keys.include?(@asset.to_sym)
      available_filters = asset_class(@asset)::SEARCH_FILTERS
      @filter = params[:filter] if available_filters.include?(params[:filter])
    end
  end

  def limit
    if map_search?(@searches)
      MAP_SEARCH_LIMIT
    elsif !multiple_search?
      if [:people, :communities, :enterprises].include? @asset
        BLOCKS_SEARCH_LIMIT
      else
        LIST_SEARCH_LIMIT
      end
    else
      MULTIPLE_SEARCH_LIMIT
    end
  end

  def paginate_options(page = params[:page])
    page = 1 if multiple_search?(@searches) || params[:display] == 'map'
    { :per_page => limit, :page => page }
  end

  def full_text_search
    @searches[@asset] = find_by_contents(@asset, @scope, @query, paginate_options, {:category => @category, :filter => @filter})
  end

  private

  def visible_profiles(klass, *extra_relations)
    relations = [:image, :domains, :environment, :preferred_domain]
    relations += extra_relations
    @environment.send(klass.name.underscore.pluralize).visible.includes(relations)
  end

end
