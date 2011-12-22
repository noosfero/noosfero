class SearchController < PublicController

  helper TagsHelper

  before_filter :load_category
  before_filter :prepare_filter
  before_filter :check_search_whole_site
  before_filter :load_search_assets
  before_filter :check_valid_assets, :only => [ :assets ]

  no_design_blocks

  protected

  def load_search_assets
    @search_in = where_to_search
    @searching = {}
    @search_in.each do |key, name|
      @searching[key] = (params[:asset].blank? && (params[:find_in].nil? || params[:find_in].empty? || params[:find_in].include?(key.to_s))) || (params[:asset] == key.to_s)
    end
  end

  def prepare_filter
    if @category
      @noosfero_finder = CategoryFinder.new(@category)
    else
      @noosfero_finder = EnvironmentFinder.new(@environment)
    end
  end

  def check_search_whole_site
    if params[:search_whole_site_yes] or params[:search_whole_site] == 'yes'
      redirect_to params.merge(:category_path => [], :search_whole_site => nil, :search_whole_site_yes => nil)
    end
  end

  def check_valid_assets
    @asset = params[:asset].to_sym
    if !where_to_search.map(&:first).include?(@asset)
      render :text => 'go away', :status => 403
      return
    end
  end

  def events
    @category_id = @category ? @category.id : nil

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

    events = @results[:events]

    @calendar = populate_calendar(date, events)
    @previous_calendar = populate_calendar(date - 1.month, events)
    @next_calendar = populate_calendar(date + 1.month, events)
  end

  def people
    #nothing, just to enable
  end
  def enterprises
    load_product_categories_menu(:enterprises)
    @categories_menu = true
  end
  def communities
    #nothing, just to enable
  end
  def articles
    #nothins, just to enable
  end

  def products
    load_product_categories_menu(:products)
    @categories_menu = true
  end

  def load_product_categories_menu(asset)
    @results[asset].uniq!
    # REFACTOR DUPLICATED CODE inner loop doing the same thing that outter loop

    if !@query.blank? || @region && !params[:radius].blank?
      ret = @noosfero_finder.find(asset, @query, calculate_find_options(asset, nil, params[:page], @product_category, @region, params[:radius], params[:year], params[:month]).merge({:limit => :all}))
      @result_ids = ret.is_a?(Hash) ? ret[:results] : ret
    end

  end

  def calculate_find_options(asset, limit, page, product_category, region, radius, year, month)
    result = { :product_category => product_category, :per_page => limit, :page => page }
    if [:enterprises, :people, :products].include?(asset) && region
      result.merge!(:within => radius, :region => region.id)
    end

    if month || year
      date = Date.new(year.to_i, month.to_i, 1)
      result[:date_range] = (date - 1.month)..(date + 1.month).at_end_of_month
    end

    result
  end

  # limit the number of results per page
  # TODO: dont hardcore like this
  def limit
    searching = @searching.values.select{|v|v}
    if params[:display] == 'map'
      2000
    else
      (searching.size == 1) ? 20 : 6
    end
  end

  public

  include SearchHelper

  ######################################################

  def where_to_search
    [
      [ :articles, N_('Articles') ],
      [ :enterprises, N_('Enterprises') ],
      [ :people, N_('People') ],
      [ :communities, N_('Communities') ],
      [ :products, N_('Products') ],
      [ :events, N_('Events') ]
    ].select {|key, name| !environment.enabled?('disable_asset_' + key.to_s) }
  end

  def cities
    @cities = City.find(:all, :order => 'name', :conditions => ['parent_id = ? and lat is not null and lng is not null', params[:state_id]])
    render :action => 'cities', :layout => false
  end
  
  def complete_region
    # FIXME this logic should be in the model
    @regions = Region.find(:all, :conditions => [ '(name like ? or name like ?) and lat is not null and lng is not null', '%' + params[:region][:name] + '%', '%' + params[:region][:name].capitalize + '%' ])
    render :action => 'complete_region', :layout => false
  end

  def index
    @query = params[:query] || ''
    @product_category = ProductCategory.find(params[:product_category]) if params[:product_category]

    @region = City.find_by_id(params[:city]) if !params[:city].blank? && params[:city] =~ /^\d+$/

    # how many assets we are searching for?
    number_of_result_assets = @searching.values.select{|v| v}.size

    @results = {}
    @facets = {}
    @order = []
    @names = {}

    where_to_search.select { |key,description| @searching[key]  }.each do |key, description|
      @order << key
      find_options = calculate_find_options(key, limit, params[:page], @product_category, @region, params[:radius], params[:year], params[:month]);
      ret = @noosfero_finder.find(key, @query, find_options)
      @results[key] = ret.is_a?(Hash) ? ret[:results] : ret
      @facets[key] = ret.is_a?(Hash) ? ret[:facets] : {}
      @names[key] = getterm(description)
    end

    if @results.keys.size == 1
      specific_action = @results.keys.first
      if respond_to?(specific_action)
        @asset_name = getterm(@names[@results.keys.first])
        send(specific_action)
        render :action => specific_action
        return
      end
    end

    render :action => 'index'
  end

  alias :assets :index

  #######################################################

  # view the summary of one category
  def category_index
    @results = {}
    @order = []
    @names = {}
    [
      [ :people, _('People'), @noosfero_finder.recent('people', limit) ],
      [ :enterprises, __('Enterprises'), @noosfero_finder.recent('enterprises', limit) ],
      [ :products, _('Products'), @noosfero_finder.recent('products', limit) ],
      [ :events, _('Upcoming events'), @noosfero_finder.upcoming_events({:per_page => limit}) ],
      [ :communities, __('Communities'), @noosfero_finder.recent('communities', limit) ],
      [ :most_commented_articles, _('Most commented articles'), @noosfero_finder.most_commented_articles(limit) ],
      [ :articles, _('Articles'), @noosfero_finder.recent('text_articles', limit) ]
    ].each do |key, name, list|
      @order << key
      @results[key] = list
      @names[key] = name
    end
  end
  attr_reader :category

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

  #######################################################

  def popup
    @regions = Region.find(:all).select{|r|r.lat && r.lng}
    render :action => 'popup', :layout => false
  end

  def events_by_day
    @selected_day = build_date(params[:year], params[:month], params[:day])
    if params[:category_id] and Category.exists?(params[:category_id])
      @events_of_the_day = environment.events.by_day(@selected_day).in_category(Category.find(params[:category_id]))
    else
      @events_of_the_day = environment.events.by_day(@selected_day)
    end
    render :partial => 'events/events_by_day'
  end

end
