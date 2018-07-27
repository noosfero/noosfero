class SearchController < PublicController

  helper TagsHelper
  include SearchHelper
  include ActionView::Helpers::NumberHelper
  include SanitizeParams


  before_action :sanitize_params
  before_action :redirect_asset_param, :except => [:assets, :suggestions]
  before_action :load_category, :except => :suggestions
  before_action :load_tag, :except => :suggestions
  before_action :load_search_assets, :except => :suggestions
  before_action :load_query, :except => :suggestions
  before_action :load_order, :except => :suggestions
  before_action :load_templates, :except => :suggestions
  before_action :load_kind, :only => [:people, :enterprises, :communities]

  # Backwards compatibility with old URLs
  def redirect_asset_param
    return unless params.has_key?(:asset)
    redirect_to url_for(params.merge action: params.delete(:asset))
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
    @scope = @environment.articles.accessible_to(user)
    full_text_search
  end

  def contents
    redirect_to url_for(params.merge action: :articles)
  end

  def people
    @scope = visible_profiles(Person)
    @scope = @scope.with_kind(@kind) if @kind.present?
    full_text_search
  end

  def enterprises
    @scope = visible_profiles(Enterprise)
    @scope = @scope.with_kind(@kind) if @kind.present?
    full_text_search
  end

  # keep URL compatibility
  def products
    return render_not_found unless defined? ProductsPlugin
    redirect_to url_for(params.merge controller: 'products_plugin/search', action: :products)
  end

  def communities
    @scope = visible_profiles(Community)
    @scope = @scope.with_kind(@kind) if @kind.present?
    full_text_search
  end

  def events
    load_events!
    if @category
      @events = @events.in_category(Category.find(@category_id))
    end

    @scope = @events
    full_text_search
    @calendar = populate_calendar(@date, @events)
    @events = @events.paginate(:per_page => per_page, :page => params[:page])
  end

  def events_by_date
    load_events!
    @events = @events.paginate(:per_page => per_page, :page => params[:page])
    render :partial => 'events/events', locals: { xhr_links: true }
  end

  # keep old URLs workings
  def assets
    params[:action] = params[:asset].is_a?(Array) ? :index : params.delete(:asset)
    redirect_to url_for(params)
  end

  def tags
    @tags_cache_key = "tags_env_#{environment.id.to_s}"
    if is_cache_expired?(@tags_cache_key)
      @tags = environment.environment_tags
    end
  end

  def tag
    tag_str = @tag.kind_of?(Array) ? @tag.join(" ") : @tag.to_str
    @tag_cache_key = "tag_#{CGI.escape(tag_str)}_env_#{environment.id.to_s}_page_#{params[:npage]}"
    if is_cache_expired?(@tag_cache_key)
      send(:index)
      @asset = :tag
    end
  end

  def suggestions
    render plain: find_suggestions(normalize_term(params[:term]), environment, params[:asset]).to_json
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

  def load_tag
    @tag = params[:tag]
  end

  def load_category
    if params[:category_path].blank?
      render_not_found if params[:action] == 'category_index'
    else
      path = params[:category_path]
      @category = environment.categories.find_by path: path
      if @category.nil?
        render_not_found(path)
      else
        @category_id = @category.id
      end
    end
  end

  def available_searches
    @available_searches ||= {
      articles:    _('Contents'),
      people:      _('People'),
      communities: _('Communities'),
      enterprises: _('Enterprises'),
      events:      _('Events'),
    }
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
      @searching[key] = params[:action] == 'index' || params[:action] == 'tag' || params[:action] == key.to_s
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

  def load_kind
    if params[:kind].present?
      @kind = Kind.find_by(name: params[:kind])
      render_not_found(params[:kind]) unless @kind.present?
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
    options = {:category => @category, :tag => @tag, :order => @order,
               :display => params[:display], :template_id => params[:template_id],
               :facets => params[:facets], :periods => params[:periods]}

    @filters = load_filters options
    @searches[@asset] = find_by_contents(@asset, environment, @scope, @query,
                          paginate_options, options)
  end

  private

  def visible_profiles(klass, *extra_relations)
    relations = [:image, :domains, :environment, :preferred_domain]
    relations += extra_relations
    @environment.send(klass.name.underscore.pluralize).accessible_to(user).visible.includes(relations)
  end

  def per_page
    20
  end

  def available_assets
    {
      articles:    _('Contents'),
      enterprises: _('Enterprises'),
      people:      _('People'),
      communities: _('Communities'),
    }
  end

  def load_events!
    begin
      @date = build_date params[:year], params[:month], params[:day]
    rescue ArgumentError # invalid date
      return render_not_found
    end

    if params[:year] && params[:month] && params[:day]
      @events = environment.events.by_day(@date)
    else
      @events = environment.events.by_month(@date)
    end
  end
end
