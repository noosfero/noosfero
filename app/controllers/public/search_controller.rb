class SearchController < PublicController

  helper TagsHelper
  include SearchHelper
  include ActionView::Helpers::NumberHelper

  before_filter :redirect_asset_param, :except => [:assets, :suggestions]
  before_filter :load_category, :except => :suggestions
  before_filter :load_search_assets, :except => :suggestions
  before_filter :load_query, :except => :suggestions
  before_filter :load_order, :except => :suggestions
  before_filter :load_templates, :except => :suggestions

  # Backwards compatibility with old URLs
  def redirect_asset_param
    return unless params.has_key?(:asset)
    redirect_to params.merge(:action => params.delete(:asset))
  end

  no_design_blocks

  def index
    @searches = {}
    @assets = []
    @names = {}
    @results_only = true

    @enabled_searches.select { |key,description| @searching[key] }.each do |key, description|
      load_query
      @asset = key
      send(key)
      @assets << key
      @names[key] = _(description)
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
    @assets = []
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
      @assets << asset
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
    @scope = visible_profiles(Enterprise)
    full_text_search
  end

  def communities
    @scope = visible_profiles(Community)
    full_text_search
  end

  def events
    if params[:year].blank? && params[:year].blank? && params[:day].blank?
      @date = DateTime.now
    else
      year = (params[:year] ? params[:year].to_i : DateTime.now.year)
      month = (params[:month] ? params[:month].to_i : DateTime.now.month)
      day = (params[:day] ? params[:day].to_i : 1)
      @date = build_date(year, month, day)
    end
    date_range = (@date - 1.month).at_beginning_of_month..(@date + 1.month).at_end_of_month

    @events = []
    if params[:day] || !params[:year] && !params[:month]
      @events = @category ?
        environment.events.by_day(@date).in_category(Category.find(@category_id)).paginate(:per_page => per_page, :page => params[:page]) :
        environment.events.by_day(@date).paginate(:per_page => per_page, :page => params[:page])
    elsif params[:year] || params[:month]
      @events = @category ?
        environment.events.by_month(@date).in_category(Category.find(@category_id)).paginate(:per_page => per_page, :page => params[:page]) :
        environment.events.by_month(@date).paginate(:per_page => per_page, :page => params[:page])
    end

    @scope = date_range && params[:action] == 'events' ? environment.events.by_range(date_range) : environment.events
    full_text_search

    events = @searches[@asset][:results]
    @calendar = populate_calendar(@date, events)
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
      @searches[@asset] = {:results => environment.articles.tagged_with(@tag).paginate(paginate_options)}
    end
  end

  def events_by_day
    @date = build_date(params[:year], params[:month], params[:day])
    @events = environment.events.by_day(@date).paginate(:per_page => per_page, :page => params[:page])
    render :partial => 'events/events'
  end

  def suggestions
    render :text => find_suggestions(normalize_term(params[:term]), environment, params[:asset]).to_json
  end

  #######################################################
  protected

  def load_query
    @asset = (params[:asset] || params[:action]).to_sym
    @assets ||= [@asset]
    @searches ||= {}

    @query = params[:query] || ''
    @empty_query = @category.nil? && @query.blank?
  end

  def load_category
    if params[:category_path].blank?
      render_not_found if params[:action] == 'category_index'
    else
      path = params[:category_path]
      @category = environment.categories.find_by_path(path)
      if @category.nil?
        render_not_found(path)
      else
        @category_id = @category.id
      end
    end
  end

  def available_searches
    @available_searches ||= ActiveSupport::OrderedHash[
      :articles, _('Contents'),
      :people, _('People'),
      :communities, _('Communities'),
      :enterprises, _('Enterprises'),
      :products, _('Products and Services'),
      :events, _('Events'),
    ]
  end

  def load_search_assets
    if available_searches.keys.include?(params[:action].to_sym) && environment.enabled?("disable_asset_#{params[:action]}")
      render_not_found
      return
    end

    @enabled_searches = available_searches.select {|key, name| environment.disabled?("disable_asset_#{key}") }
    @searching = {}
    @titles = {}
    @enabled_searches.each do |key, name|
      @titles[key] = _(name)
      @searching[key] = params[:action] == 'index' || params[:action] == key.to_s
    end
    @names = @titles if @names.nil?
  end

  def load_order
    @order = 'more_recent'
    if available_searches.keys.include?(@asset.to_sym)
      available_orders = asset_class(@asset)::SEARCH_FILTERS[:order]
      @order = params[:order] if available_orders.include?(params[:order])
    end
  end

  def load_templates
    @templates = {}
    @templates[@asset] = environment.send(@asset.to_s).templates if [:people, :enterprises, :communities].include?(@asset)
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
    @searches[@asset] = find_by_contents(@asset, environment, @scope, @query, paginate_options, {:category => @category, :filter => @order, :template_id => params[:template_id]})
  end

  private

  def visible_profiles(klass, *extra_relations)
    relations = [:image, :domains, :environment, :preferred_domain]
    relations += extra_relations
    @environment.send(klass.name.underscore.pluralize).visible.includes(relations)
  end

  def per_page
    20
  end

  def available_assets
    assets = ActiveSupport::OrderedHash[
      :articles, _('Contents'),
      :enterprises, _('Enterprises'),
      :people, _('People'),
      :communities, _('Communities'),
      :products, _('Products and Services'),
    ]
  end

end
