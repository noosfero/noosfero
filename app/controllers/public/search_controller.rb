class SearchController < PublicController

  helper TagsHelper
  include SearchHelper
  include ActionView::Helpers::NumberHelper

  before_filter :redirect_asset_param, :except => :assets
  before_filter :load_category
  before_filter :load_search_assets
  before_filter :load_query
  before_filter :load_search_engine

  # Backwards compatibility with old URLs
  def redirect_asset_param
    return unless params.has_key?(:asset)
    redirect_to params.merge(:action => params.delete(:asset))
  end

  no_design_blocks

  def articles
    if @search_engine && !@empty_query
      full_text_search
    else
      @results[@asset] = @environment.articles.public.send(@filter).paginate(paginate_options)
    end
    render :template => 'search/search_page'
  end

  def contents
    redirect_to params.merge(:action => :articles)
  end

  def people
    if @search_engine && !@empty_query
      full_text_search
    else
      @results[@asset] = visible_profiles(Person).send(@filter).paginate(paginate_options)
    end
    render :template => 'search/search_page'
  end

  def products
    if @search_engine
      full_text_search
    else
      @results[@asset] = @environment.products.send(@filter).paginate(paginate_options)
    end
    render :template => 'search/search_page'
  end

  def enterprises
    if @search_engine && !@empty_query
      full_text_search
    else
      @filter_title = _('Enterprises from network')
      @results[@asset] = visible_profiles(Enterprise, [{:products => :product_category}]).paginate(paginate_options)
    end
    render :template => 'search/search_page'
  end

  def communities
    if @search_engine && !@empty_query
      full_text_search
    else
      @results[@asset] = visible_profiles(Community).send(@filter).paginate(paginate_options)
    end
    render :template => 'search/search_page'
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

    if @search_engine && !@empty_query
      full_text_search
    else
      @results[@asset] = date_range ? environment.events.by_range(date_range) : environment.events
    end

    events = @results[@asset]
    @calendar = populate_calendar(date, events)
    @previous_calendar = populate_calendar(date - 1.month, events)
    @next_calendar = populate_calendar(date + 1.month, events)
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
    params[:display] ||= 'list'
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

  def load_search_engine
    @search_engine = @plugins.first_plugin(:search_engine?)
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
      @searching[key] = params[:action] == key.to_s
    end
    @names = @titles if @names.nil?
  end

  def limit
    if map_search?
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
    page = 1 if multiple_search? or @display == 'map'
    { :per_page => limit, :page => page }
  end

  def full_text_search(options = {})
    @results[@asset] = @plugins.first(:full_text_search, @asset, @query, @category, paginate_options(params[:page]))
  end

  private

  def visible_profiles(klass, *extra_relations)
    relations = [:image, :domains, :environment, :preferred_domain]
    relations += extra_relations
    @environment.send(klass.name.underscore.pluralize).visible.includes(relations)
  end

end
